require_relative "analysis/file_map"
require_relative "find_association"
require "active_support/all"
require "json"

class Lsp
  def call
    file_map = Analysis::FileMap.new

    #VS Code

    loop do
      buffer = STDIN.gets("\r\n\r\n")
      content_length = buffer.match(/Content-Length: (\d+)/i)[1].to_i
      message = STDIN.read(content_length) or raise
      request = JSON.parse(message, symbolize_names: true)
      log_message(request, :method)

      case request[:method]
      when "initialize"
        file_map.root_path = request[:params][:rootPath]
        respond(request)
      when "textDocument/didOpen"
        file_uri = request[:params][:textDocument][:uri]
        content = request[:params][:textDocument][:text]

        file_map.upsert(file_uri:, content:)
        log("Opened #{file_uri}")
        notification_response(request, file_map)
      when "textDocument/didChange"
        file_uri = request[:params][:textDocument][:uri]

        request[:params][:contentChanges].each do |change|
          file_map.upsert(file_uri:, content: change[:text])
        end
        log("Contents Updated")
        notification_response(request, file_map)
      when "textDocument/hover"
        hover_response(request, file_map)
      when "textDocument/definition"
        log("DEFINITION")

        definition_response(request, file_map)
      when "textDocument/codeAction"
        code_action_response(request, file_map)
      when "textDocument/completion"
        completion_provider_response(request)
      end
    end
  end

  private

  def notification_response(request, file_map)
    uri = request[:params][:textDocument][:uri]
    content = file_map.hash[uri]

    line = nil
    search_word = "VS Code"
    content.split("\n").each_with_index do |text_line, index|
      if text_line.include?(search_word)
        line = index
      end
    end

    unless line.nil?
      response = {
        jsonrpc: "2.0",
        method: "textDocument/publishDiagnostics",
        params: {
          uri:,
          diagnostics: [
            {
              range: {
                start: {
                  line: line,
                  character: 0
                },
                end: {
                  line: line,
                  character: 0
                }
              },
              severity: 1,
              source: "Common Sense",
              message: "Please use a good editor",
            }
          ]
        }
      }.to_json

      write_to_stdout(response)
    end
  end

  def completion_provider_response(request)
    response = {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        items: [
          {
            label: "Neovim (BTW)", 
            detail: "Very cool editor", 
            documentation: "It's quite fun",
          }
        ]
      }
    }.to_json

    write_to_stdout(response)
  end

  def code_action_response(request, file_map)
    uri = request[:params][:textDocument][:uri]
    content = file_map.hash[uri]

    line = nil 
    character = nil
    search_word = "VS Code"
    content.split("\n").each_with_index do |text_line, index|
      if text_line.include?(search_word)
        line = index 
        character = text_line.index(search_word)
        break
      end
    end

    unless line.nil?
      response = {
        jsonrpc: "2.0",
        id: request[:id],
        result: [
          {
            title: "Replace VS code with a superior editor",
            edit: {
              changes: {
                uri => [
                  {
                    range: {
                      start: {
                        line:,
                        character:
                      },
                      end: {
                        line:,
                        character: character + search_word.size
                      }
                    },
                    newText: "Neovim"
                  }
                ]
              }
            }
          }
        ]
      }.to_json

      write_to_stdout(response)
    end
  end

  def definition_response(request, file_map)
    uri = request[:params][:textDocument][:uri]
    line_number = request[:params][:position][:line].to_s
    line = file_map.hash_lines[uri][line_number]

    association = FindAssociation.new(
      line_text: line,
      file_uri: uri,
      root_path: file_map.root_path
    ).call

    log("FILE")
    log(association.path)

    if association.path
      response = {
        jsonrpc: "2.0",
        id: request[:id],
        result: {
          uri: "file://#{association.path}",
          range: {
            start: {
              line: association.start_line,
              character: 0
            },
            end: {
              line: 0,
              character: 0
            }
          }
        }
      }.to_json

      write_to_stdout(response)
    end
  end

  def hover_response(request, file_map)
    file_uri = request[:params][:textDocument][:uri]
    characters = file_map.hash[file_uri].length
    response = {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        contents: "File: #{file_uri}, Characters: #{characters}"
      }
    }.to_json

    write_to_stdout(response)
  end

  def respond(request)
    response = {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        capabilities: {
          textDocumentSync: 1,
          hoverProvider: true,
          definitionProvider: true,
          codeActionProvider: true,
          completionProvider: {},
        },
        serverInfo: {
          name: "educationlsp",
          version: "0.0.0.0.0.0-beta1.final"
        } 
      }
    }.to_json

    write_to_stdout(response)
  end

  def write_to_stdout(json)
    json_string = "Content-Length: #{json.bytesize}\r\n\r\n#{json}"
    stdout = STDOUT.binmode

    stdout.print json_string
    $stdout.flush

    log("Sending response")
  end

  def log_message(request, key)
   # File.open("log.txt", "a") do |f|
   #   f.write "Received message with #{request[key]}\n"
   # end
  end

  def log(message)
    File.open("/home/catalin/.local/state/nvim/lsp.log", "a") do |f|
      f.write "#{message}\n"
    end
  end
end

Lsp.new.call
