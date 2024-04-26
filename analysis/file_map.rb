module Analysis
  class FileMap
    attr_accessor :hash, :hash_lines

    def initialize
      @hash = {}
      @hash_lines = {}
    end

    def upsert(file_uri:, content:)
      hash.merge!(file_uri => content)
      hash_lines.merge!(file_uri => content)
      lines(file_uri:)
    end

    private

    def lines(file_uri:)

      array_of_file_lines = hash_lines[file_uri].split("\n")
      hash_lines[file_uri] = {}

      array_of_file_lines.each_with_index do |line, index|
        hash_lines[file_uri].merge!({ index.to_s => line })
      end
    end

    def log(message)
      File.open("log.txt", "a") do |f|
        f.write "#{message}\n"
      end
    end
  end
end
