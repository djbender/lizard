require "rails_helper"

RSpec.describe "API V1 TestRuns", type: :request do
  let!(:project) { Project.create!(name: "Test Project") }
  let(:valid_attributes) do
    {
      test_run: {
        commit_sha: "abc123",
        branch: "main",
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.5,
        coverage: 85.2,
        ran_at: Time.current
      }
    }
  end

  describe "POST /api/v1/test_runs" do
    context "with valid API key" do
      let(:headers) { { "X-API-Key" => project.api_key } }

      it "creates a new test run" do
        expect {
          post "/api/v1/test_runs", params: valid_attributes, headers: headers
        }.to change(TestRun, :count).by(1)
      end

      it "returns success response" do
        post "/api/v1/test_runs", params: valid_attributes, headers: headers
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to include("status" => "success")
      end

      it "associates test run with correct project" do
        post "/api/v1/test_runs", params: valid_attributes, headers: headers
        test_run = TestRun.last
        expect(test_run.project).to eq(project)
      end

      it "stores all test run attributes" do
        post "/api/v1/test_runs", params: valid_attributes, headers: headers
        test_run = TestRun.last
        
        expect(test_run.commit_sha).to eq("abc123")
        expect(test_run.branch).to eq("main")
        expect(test_run.ruby_specs).to eq(100)
        expect(test_run.js_specs).to eq(50)
        expect(test_run.runtime).to eq(30.5)
        expect(test_run.coverage).to eq(85.2)
      end
    end

    context "without API key" do
      it "returns unauthorized error" do
        post "/api/v1/test_runs", params: valid_attributes
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid API key")
      end
    end

    context "with invalid API key" do
      let(:headers) { { "X-API-Key" => "invalid-key" } }

      it "returns unauthorized error" do
        post "/api/v1/test_runs", params: valid_attributes, headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid API key")
      end

      it "does not create a test run" do
        expect {
          post "/api/v1/test_runs", params: valid_attributes, headers: headers
        }.not_to change(TestRun, :count)
      end
    end

    context "with invalid parameters" do
      let(:headers) { { "X-API-Key" => project.api_key } }
      let(:invalid_attributes) { { test_run: { branch: "" } } }

      it "creates test run even with minimal data" do
        expect {
          post "/api/v1/test_runs", params: invalid_attributes, headers: headers
        }.to change(TestRun, :count).by(1)
        
        expect(response).to be_successful
      end
    end
  end
end