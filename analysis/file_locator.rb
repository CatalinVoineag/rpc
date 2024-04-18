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
      array = uri.split("/")
      array.pop
      root_path = nil

      loop do
        break if array.empty?

        root_path = array.join("/")
        root_path = "#{root_path}/.git"

        terminal = IO.popen("[ -d /#{root_path} ] && echo true")
          break if terminal.gets&.strip == "true"
        terminal.close

        array.pop
      end

      puts root_path
    end
  end
end
