require "active_support/all"
require 'byebug'

Association = Struct.new(:path, :start_line)

class FindAssociation
  attr_reader :line_text, :file_uri, :file_name, :root_path
  private :line_text, :file_uri, :file_name, :root_path

  def initialize(line_text:, file_uri:, root_path:)
    @line_text = line_text
    @file_uri = file_uri.gsub('file://', '')
    @file_name = @file_uri.split('/')[-1]
    @root_path = root_path
  end

  def call
    association = Association.new
    if line_text.include?('belongs_to') ||
        line_text.include?('has_many') ||
        line_text.include?('has_one')
      association_file = if line_text.include?('class_name:')
                           get_class_name_file(line_text)
                         elsif line_text.include?('through:')
                           get_through_file(line_text)
                         else
                           get_association_file(line_text)
                         end

      association_path = get_association_path(root_path, association_file)
      log('FILE URI')
      log(file_uri)
      log('ASOC PATH')
      log(association_path)
      log('ROOT')
      log(root_path)
      if File.exist?(association_path)
        association.path = association_path
        association.start_line = find_start_line(
          association_path,
          association_file
        )
      end
    end
    association
  end

  private

  def get_association_path(root_path, association_file)
    current_namespace = file_uri.gsub(root_path, '')
    association_namespace = current_namespace.gsub(file_name, association_file)

    root_path + association_namespace
  end

  def get_association_file(line_text)
    array_of_words = line_text.split
    first_word = array_of_words.first
    file = array_of_words [array_of_words.index(first_word) + 1]
    sanitized_file = file.gsub(':', '').gsub(',', '')

    "#{sanitized_file.singularize}.rb"
  end

  def get_through_file(line_text)
    array_of_words = line_text.split
    through_value = array_of_words[array_of_words.index('through:') + 1]
    sanitized_value = through_value.gsub(':', '').gsub(',', '').gsub("'", '')

    "#{sanitized_value.singularize}.rb"
  end

  def get_class_name_file(line_text)
    array_of_words = line_text.split
    class_name = array_of_words[array_of_words.index('class_name:') + 1].gsub("'", '')
    class_name_file = class_name.delete(',').underscore

    "#{class_name_file}.rb"
  end

  def find_start_line(path, association_file_name)
    association_file_name.gsub!('.rb', '')
    class_name = association_file_name.split('_').map(&:capitalize).join

    terminal = IO.popen("grep -in -h --no-filename class #{class_name} #{path}")
    lines = terminal.readlines
    terminal.close

    lines.first.split(':').first.to_i - 1
  end

  def log(message)
    File.open('/home/catalin/.local/state/nvim/lsp.log', 'a') do |f|
      f.write "#{message}\n"
    end
  end
end
