require "active_support/all"

Klass = Struct.new(:path)

class FindClass
  attr_reader :line, :uri, :file_name, :root_path, :char_number
  private :line, :uri, :file_name, :root_path, :char_number

  def initialize(line:, uri:, root_path:, char_number:)
    @line= line.strip
    @uri = uri.gsub("file://", "")
    @file_name = @uri.split("/")[-1]
    @root_path = root_path
    @char_number = char_number
  end

  def letter_or_colon?(char)
    return if char.nil?

    char.match?(/[[:alpha:][:]]/)
  end

  def first_char
    char_number.downto(0) do |i|
      if !letter_or_colon?(line[i])
        return i + 1
      end
    end
  end

  def last_char
    char_number.upto(line.size) do |i|
      if !letter_or_colon?(line[i])
        return i - 1
      end
    end
  end

  def call
    # works OK only for components
    klass = Klass.new
    klass_name = line[first_char..last_char]

    return unless klass_name

    log("KLASS NAME")
    log(klass_name)
    klass_path = klass_name.gsub('::', '/').underscore.downcase + '.rb'
    component_path = "#{root_path}/app/components"

    log("KLASS PATH")
    log(klass_path)

    full_klass_path = "#{component_path}/#{klass_path}"

    if File.exist?(full_klass_path)
      klass.path = full_klass_path
    else
      component_directories = Dir.glob("#{component_path}/*/")

      component_directories.each do |directory|
        full_klass_path = "#{directory}#{klass_path}"
        if File.exist?(full_klass_path)
          klass.path = full_klass_path
          break
        end
      end
    end

    klass
  end

  private

  def log(message)
    File.open("/home/catalin/.local/state/nvim/lsp.log", "a") do |f|
      f.write "#{message}\n"
    end
  end
end
