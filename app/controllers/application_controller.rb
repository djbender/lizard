class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Basic authentication for production
  # :nocov:
  if Rails.env.production? && ENV["BASIC_AUTH_USERNAME"] && ENV["BASIC_AUTH_PASSWORD"]
    http_basic_authenticate_with name: ENV["BASIC_AUTH_USERNAME"], password: ENV["BASIC_AUTH_PASSWORD"]
  end
  # :nocov:

  clear_helpers
  helper Importmap::ImportmapTagsHelper

  def self.inherited(subclass)
    super
    controller_name = subclass.name.underscore.gsub("_controller", "")
    helper_name = controller_name.split("/").last

    # Always include application helper
    subclass.helper :application

    # Include controller-specific helper if it exists
    if File.exist?(Rails.root.join("app/helpers/#{helper_name}_helper.rb"))
      subclass.helper helper_name.to_sym
    end

    # Include projects helper for controllers that need project-related functionality
    if ["dashboard"].include?(helper_name) && File.exist?(Rails.root.join("app/helpers/projects_helper.rb"))
      subclass.helper :projects
    end
  end
end
