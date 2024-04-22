require_relative "find_root_directory"

Association = Struct.new(:path, :start_line)

class FindAssociation
  attr_reader :line_text, :file_uri
  private :line_text, :file_uri

  def initialize(line_text:, file_uri:)
    @line_text = line_text
    @file_uri = file_uri.gsub("file://", "")
  end

  def call
    association = Association.new
    if line_text.include?("belongs_to") || line_text.include?("has_many")
      association_file = "#{line_text.split(":")[1]}.rb"
      root_path = FindRootDirectory.call(file_uri)
      association_path = "#{root_path}/app/models/#{association_file}"

      log("FILE URI")
      log(file_uri)
      log("ASOC FILE")
      log(association_file)
      log("ROOT")
      log(root_path)
      log("ASOC PATH")
      log(association_path)
      if File.exist?(association_path)
        log("FOUND!!!")
        association.path = association_path
        association.start_line = find_start_line(
          association_path,
          association_file
        )
      end
    end

    association
  end

#  private

  def find_start_line(path, association_file_name)
    line = nil
    association_file_name.gsub!(".rb", "")
    class_name = association_file_name.split("_").map(&:capitalize).join

    terminal = IO.popen("grep -in -h --no-filename class #{class_name} #{path}")
      lines = terminal.readlines
    terminal.close

    line = lines.first.split(":").first.to_i - 1
    line
  end

  def log(message)
    File.open("log.txt", "a") do |f|
      f.write "#{message}\n"
    end
  end
end
