require "active_support/all"

module Analysis
  class FileMap
    attr_accessor :hash, :hash_lines, :lines_with_indents, :root_path

    def initialize
      @hash = {}
      @hash_lines = {}
      @lines_with_indents = {}
    end

    def upsert(file_uri:, content:)
      hash.merge!(file_uri => content)
      hash_lines.merge!(file_uri => content)
      #blocks.merge!(file_uri => calculate_blocks(file_uri))
      lines_with_indents.merge!(file_uri => calculate_lines(file_uri))
      lines(file_uri:)
    end

    private

    def calculate_lines(file_uri)
      array_of_file_lines = hash_lines[file_uri].split("\n")
      hash = {}

      array_of_file_lines.each_with_index do |line, index|
        hash[index.to_s] = { content: line.strip, indents: number_of_indents(line) }
      end

      hash
    end

    def calculate_blocks(file_uri)
      array_of_file_lines = hash_lines[file_uri].split("\n")

      array_of_file_lines.map do |line|
        { number_of_indents(line) => line.strip }
      end
    end

    def number_of_indents(line)
      number = 0
      line.split('  ').map do |element|
        break unless element.blank?

        number += 1 if element.blank?
      end

      number
    end

    def lines(file_uri:)
      array_of_file_lines = hash_lines[file_uri].split("\n")
      hash_lines[file_uri] = {}

      array_of_file_lines.each_with_index do |line, index|
        hash_lines[file_uri].merge!({ index.to_s => line })
      end
    end
  end
end
