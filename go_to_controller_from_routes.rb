require "active_support/all"
require "byebug"
require "byebug/core"

Controller = Struct.new(:path, :line_number)

class GoToControllerFromRoutes
  attr_reader :line, :line_number, :file_uri, :file_name, :file_map, :root_path

  def initialize(line:, line_number:, file_uri:, file_map:, root_path:)
    @line = line
    @line_number = line_number
    @file_uri = file_uri
    @file_name = @file_uri.split("/")[-1]
    @file_map = file_map
    @root_path = root_path
  end

  def call
    return unless routes_file?
    return unless route?

    controller = Controller.new
    controller.path = "#{root_path}/app/controllers/#{namespaces.join('/')}"

    controller
  end

  private

  def number_of_indents(line_text)
    number = 0
    line_text.split('  ').map do |element|
      break unless element.blank?

      number += 1 if element.blank?
    end

    number
  end

  def namespaces
    namespace = {}
    indents = number_of_indents(line)

    current_contoller = line.strip.split(' ').second.gsub(':', '').gsub(',', '').pluralize
    current_controller_name = "#{current_contoller}_controller.rb"

    namespace[indents] = current_controller_name
    indents -= 1

    file_map.hash_lines[file_uri].values[0..line_number.to_i - 1].reverse.each do |line_text|
      indents = number_of_indents(line_text)
      first_word = line_text.strip.split(' ').first

      if controller_name(first_word) && namespace[indents].blank?
        second_word = line_text.strip.split(' ').second.gsub(':', '').gsub(',', '')
        namespace[indents] = "#{second_word}"
        indents -= 1
      end
    end

    namespace.values.reverse
  end

  def routes_file?
    uri_stricute = file_uri.gsub("file://", "").split('/')
    if uri_stricute.include?('config') &&
        (uri_stricute.include?('routes') || uri_stricute.include?('routes.rb'))
      return true
    end
  end

  def route?
    array_of_strings = line.strip.split(' ')
    return true if array_of_strings.first == 'resources' ||
                    array_of_strings.first == 'resource' ||
                    array_of_strings.first == 'get' ||
                    array_of_strings.first == 'post' ||
                    array_of_strings.first == 'put' ||
                    array_of_strings.first == 'patch' ||
                    array_of_strings.first == 'match'
  end

  def controller_name(word)
    word == 'namespace'
  end

  def log(message)
    File.open("/home/catalin/.local/state/nvim/lsp.log", "a") do |f|
      f.write "#{message}\n"
    end
  end
end
