class SessionsController < ApplicationController
  skip_before_action :authenticate_site, only: [:new, :create]
  layout false, only: [:new]

  def new
  end

  def create
    if params[:password] == ENV["SITE_PASSWORD"]
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
