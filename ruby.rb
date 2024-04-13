require "json"

class Lsp
  attr_reader :new_message
  private :new_message

  def initialize
    @new_message = true
  end

  def call
    loop do
      buffer = STDIN.gets("\r\n\r\n")
      content_length = buffer.match(/Content-Length: (\d+)/i)[1].to_i
      message = STDIN.read(content_length) or raise
      request = JSON.parse(message, symbolize_names: true)
      log_message(request, :method)

      case request[:method]
      when "initialize"
        respond(request)
      end
    end
  end

  def respond(request)
    response = {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        capabilities: {},
        serverInfo: {
          name: "educationlsp",
          version: "0.0.0.0.0.0-beta1.final"
        } 
      }
    }.to_json

    response_string = "Content-Length: #{response.bytesize}\r\n\r\n#{response}"
    stdout = STDOUT.binmode

    stdout.print response_string
    $stdout.flush

    log("Sending response")
  end

  def log_message(request, key)
    File.open("log.txt", "a") do |f|
      f.write "Received message with #{request[key]}\n"
      f.write "Received message with #{request.keys}\n"
      f.write "Received message with #{request}\n"
    end
  end

  def log(message)
    File.open("log.txt", "a") do |f|
      f.write "#{message}\n"
    end
  end
end

Lsp.new.call
