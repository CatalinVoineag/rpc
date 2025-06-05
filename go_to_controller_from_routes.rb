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
    controller.path = controller_path

    controller
  end

  private

  def controller_path
    controller_namespace ||= namespaces  
    path = nil

    controller_namespace.each do |namespace|
      path = final_path(controller_namespace)

      if File.exist?(path)
        break
      else
        # delete second to last
        controller_namespace.delete(controller_namespace.last(2).first)
      end
    end

    path
  end

  def final_path(namespaces)
    "#{root_path}/app/controllers/#{namespaces.join('/')}"
  end

  def namespaces
    block_names = []

    level_of_indent = number_of_indents(line) - 1
    line_number.to_i.downto(0).each do |number|
      line = file_map.lines_with_indents.fetch(file_uri).fetch(number.to_s)
      content = line.fetch(:content)
      line_indent = line.fetch(:indents)
      words = content.split(' ') 
      last_word = words.last 
      first_word = words.first 

      if last_word == 'do' && level_of_indent == line_indent
        block_names << content
        level_of_indent -= 1
      end
    end

    namespaces = []

    block_names.each do |block|
      block_words = block.split(' ')
      first_word = block_words.first
      second_word = block_words.second
      if ['resources', 'resource', 'namespace'].include?(first_word)
        namespaces << second_word.gsub(/[:,]/, '')
      end
    end

    words = line.strip.split(' ')
    resrouce_name = words.second.to_s.gsub(/[:,]/, '').pluralize
    controller_filename = "#{resrouce_name}_controller.rb"

    namespaces.reverse << controller_filename
  end

  def number_of_indents(line_text)
    number = 0
    line_text.split('  ').map do |element|
      break unless element.blank?

      number += 1 if element.blank?
    end

    number
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

  def log(message)
    File.open("/home/catalin/.local/state/nvim/lsp.log", "a") do |f|
      f.write "#{message}\n"
    end
  end
end
