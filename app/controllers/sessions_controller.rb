class SessionsController < ApplicationController
  skip_before_action :authenticate_site, only: [:new, :create]
  layout false, only: [:new]

  def new
  end

  def create
    if ActiveSupport::SecurityUtils.secure_compare(
      params[:password].to_s,
      ENV["SITE_PASSWORD"].to_s
    )
      session[:authenticated] = true
      session[:login_time] = Time.current
      redirect_to root_path, notice: "Successfully logged in"
    else
      flash.now[:alert] = "Invalid password"
      render :new, status: :unauthorized
    end
  end

  def destroy
    session[:authenticated] = nil
    session[:login_time] = nil
    redirect_to login_path, notice: "Logged out successfully"
  end
end
