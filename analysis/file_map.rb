module Analysis
  class FileMap
    attr_accessor :hash 

    def initialize 
      @hash = {}
    end

    def upsert(file_uri:, content:)
      hash.merge!(file_uri => content)
    end
  end
end
