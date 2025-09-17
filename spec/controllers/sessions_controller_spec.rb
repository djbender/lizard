require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let(:valid_password) { "test123" }
  let(:invalid_password) { "wrongpassword" }

  around do |example|
    ENV["SITE_PASSWORD"] = valid_password
    Rails.application.config.disable_site_auth = false

    example.run

    ENV.delete("SITE_PASSWORD")
    Rails.application.config.disable_site_auth = true
  end

  describe "GET #new" do
    it "renders the login form" do
      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    context "with correct password" do
      it "sets session and redirects to root" do
        post :create, params: {password: valid_password}

        aggregate_failures do
          expect(session[:authenticated]).to be true
          expect(session[:login_time]).to be_within(1.second).of(Time.current)
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq("Successfully logged in")
        end
      end
    end

    context "with incorrect password" do
      it "renders login form with error" do
        post :create, params: {password: invalid_password}

        aggregate_failures do
          expect(session[:authenticated]).to be_nil
          expect(response).to have_http_status(:unauthorized)
          expect(flash[:alert]).to eq("Invalid password")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      session[:authenticated] = true
      session[:login_time] = Time.current
    end

    it "clears session and redirects to login" do
      delete :destroy

      aggregate_failures do
        expect(session[:authenticated]).to be_nil
        expect(session[:login_time]).to be_nil
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("Logged out successfully")
      end
    end
  end
end
