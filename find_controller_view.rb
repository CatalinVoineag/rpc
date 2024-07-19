require "active_support/all"

ControllerView = Struct.new(:path)

class FindControllerView
  attr_reader :line_text, :file_uri, :file_name, :root_path
  private :line_text, :file_uri, :file_name, :root_path

  def initialize(line_text:, file_uri:, root_path:)
    @line_text = line_text.strip
    @file_uri = file_uri.gsub("file://", "")
    @file_name = @file_uri.split("/")[-1]
    @root_path = root_path
  end

  def call
    return unless file_name.include?('controller') && line_text.start_with?('def ')
    controller_view = ControllerView.new

    view_name = line_text.gsub('def ', '').strip + '.html.erb'
    controller_namespace = file_name.gsub('_controller.rb', '')

    controllers_path = file_uri.gsub(root_path, '') # /app/controllers...
    views_path = controllers_path.gsub('controllers', 'views') # /app/views...
    view = "#{views_path.gsub(file_name, controller_namespace)}/#{view_name}"
    view_path = root_path + view

    log("VIEW: #{view_path}")
    if File.exist?(view_path)
      controller_view.path = view_path
    end

    controller_view
  end

  private

  def log(message)
    File.open("/home/catalin/.local/state/nvim/lsp.log", "a") do |f|
      f.write "#{message}\n"
    end
  end
end
