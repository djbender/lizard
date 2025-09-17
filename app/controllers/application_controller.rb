class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern


  before_action :authenticate_production, if: -> { Rails.env.production? && !request.path.start_with?('/api/') }

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

  private

  def authenticate_production
    unless ENV["BASIC_AUTH_USERNAME"].present? && ENV["BASIC_AUTH_PASSWORD"].present?
      render plain: "Configuration Error: Basic authentication credentials must be set in production", status: :service_unavailable
      return
    end

    authenticate_or_request_with_http_basic("Application") do |username, password|
      username == ENV["BASIC_AUTH_USERNAME"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
