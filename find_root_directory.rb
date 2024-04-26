require "byebug"

class FindRootDirectory
  attr_reader :uri
  private :uri

  def initialize(uri)
    @uri = uri
  end

  def self.call(uri)
    new(uri).call
  end

  def call
    uri_components = uri.split("/")
    root_path = nil

    loop do
      break if uri_components.empty?

      root_path = uri_components.join("/")
      root_path = "#{root_path}/.git"

      terminal = IO.popen("([ -f /#{root_path} ] || [ -d /#{root_path} ]) && echo true")
        if terminal.gets&.strip == "true"
          root_path = root_path.split("/")
          root_path.pop
          root_path = root_path.join("/")
          break
        end
      terminal.close

      uri_components.pop
    end
    return root_path unless root_path.include?(".git")
  end
end
