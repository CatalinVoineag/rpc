require "byebug"

module Analysis
  class FileLocator
    attr_accessor :uri

    def initialize(uri)
      @uri = uri
    end

    def self.call(uri)
      new(uri).call
    end

    def call
      r = IO.popen("find . ! -iwholename '*.git*' -type f | tr '\n' ','", "r+")
      arr = r.readlines
      r.close

      arr.first.split(",")
    end
  end
end
