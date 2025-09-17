class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_site, if: :should_authenticate?
  before_action :check_session_expiry, if: -> { session[:authenticated] }

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

  def should_authenticate?
    !request.path.start_with?("/api/") && !Rails.application.config.disable_site_auth
  end

  def authenticate_site
    unless ENV["SITE_PASSWORD"].present?
      render plain: "Configuration Error: SITE_PASSWORD must be set", status: :service_unavailable
      return
    end

    unless session[:authenticated]
      redirect_to login_path
    end
  end

  def check_session_expiry
    if session[:login_time] && session[:login_time] < 24.hours.ago
      session[:authenticated] = nil
      session[:login_time] = nil
      redirect_to login_path, alert: "Session expired. Please log in again."
    end
  end
end
