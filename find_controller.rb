require "active_support/all"

Controller = Struct.new(:path, :line_number, :char_number)

class FindController
  attr_reader :file_uri, :file_name, :file_map
  private :file_uri, :file_name, :file_map

  def initialize(file_uri:, file_map:)
    @file_uri = file_uri.gsub("file://", "")
    @file_name = @file_uri.split("/")[-1]
    @file_map = file_map
  end

  def call
    return unless file_uri.include?('views')
    controller = Controller.new

    controller_path = file_uri.gsub('views', 'controllers') # /app/controllers...
    controller_method = file_uri.split('/').last.split('.').first # show
    controller_path = controller_path.gsub("/#{controller_method}.html.erb", "_controller.rb") # /app/controllers/posts_controller
    line_number = 0
    char_number = 0
    controller_file = file_map.hash_lines["file://#{controller_path}"]

    if controller_file
      controller_file.each do |key, value|
        if value.strip.starts_with?("def #{controller_method}")
          line_number = key.to_i
          char_number = value.index('d')
          break
        end
      end
    end

    log("CONTROLLER PATH: #{controller_path}")
    if File.exist?(controller_path)
      controller.path = controller_path
      controller.line_number = line_number
      controller.char_number = char_number
    end

    controller
  end

  private

  def log(message)
    File.open("/home/catalin/.local/state/nvim/lsp.log", "a") do |f|
      f.write "#{message}\n"
    end
  end
end
