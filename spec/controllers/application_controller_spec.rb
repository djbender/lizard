require "rails_helper"

RSpec.describe "Application Authentication", type: :request do
  let(:valid_password) { "test123" }
  let(:session_expiry_hours) { 24 }

  shared_examples "redirects to login" do
    it "redirects to login page" do
      get "/"
      expect(response).to redirect_to("/login")
    end
  end

  shared_examples "allows access" do
    it "allows access to protected pages" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  describe "when accessing dashboard" do
    context "when in test environment" do
      include_examples "allows access"
    end

    context "when accessing API endpoints" do
      it "skips authentication for API endpoints" do
        post "/api/v1/test_runs", params: {test_data: "sample"}
        expect(response).to_not have_http_status(:service_unavailable)
        # It should return 401 from the API authentication, not from site auth
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to_not include("Configuration Error")
      end
    end
  end

  describe "authentication when enabled" do
    around do |example|
      ENV["SITE_PASSWORD"] = valid_password
      Rails.application.config.disable_site_auth = false

      example.run

      ENV.delete("SITE_PASSWORD")
      Rails.application.config.disable_site_auth = true
    end

    context "without SITE_PASSWORD configured" do
      around do |example|
        ENV.delete("SITE_PASSWORD")
        example.run
        ENV["SITE_PASSWORD"] = "test123"
      end

      it "returns configuration error" do
        get "/"

        aggregate_failures do
          expect(response).to have_http_status(:service_unavailable)
          expect(response.body).to include("Configuration Error: SITE_PASSWORD must be set")
        end
      end
    end

    context "without valid session" do
      include_examples "redirects to login"
    end

    context "with valid session" do
      before do
        valid_session = {
          authenticated: true,
          login_time: 1.hour.ago
        }
        allow_any_instance_of(ApplicationController).to receive(:session).and_return(valid_session)
      end

      include_examples "allows access"
    end

    context "with expired session" do
      before do
        expired_session = {
          authenticated: true,
          login_time: (session_expiry_hours + 1).hours.ago
        }
        allow_any_instance_of(ApplicationController).to receive(:session).and_return(expired_session)
        allow(expired_session).to receive(:[]=)
        allow(expired_session).to receive(:delete)
      end

      include_examples "redirects to login"
    end
  end
end
