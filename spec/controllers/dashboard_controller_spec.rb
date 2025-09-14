require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    context "with projects and test runs" do
      let!(:project1) { Project.create!(name: "Project 1") }
      let!(:project2) { Project.create!(name: "Project 2") }
      let!(:test_run1) { project1.test_runs.create!(branch: "main", coverage: 85.0, ruby_specs: 100, js_specs: 50, runtime: 30.0, ran_at: 2.days.ago) }
      let!(:test_run2) { project1.test_runs.create!(branch: "feature", coverage: 90.0, ruby_specs: 110, js_specs: 55, runtime: 25.0, ran_at: 1.day.ago) }
      let!(:test_run3) { project2.test_runs.create!(branch: "main", coverage: 75.0, ruby_specs: 80, js_specs: 40, runtime: 35.0, ran_at: 3.hours.ago) }

      it "returns a successful response" do
        get root_path
        expect(response).to be_successful
      end

      it "displays project names" do
        get root_path
        expect(response.body).to include("Project 1")
        expect(response.body).to include("Project 2")
      end

      it "displays recent test run data" do
        get root_path
        expect(response.body).to include("85.0%")
        expect(response.body).to include("90.0%") 
        expect(response.body).to include("75.0%")
      end

      it "renders dashboard title" do
        get root_path
        expect(response.body).to include("Test Metrics Dashboard")
      end
    end

    context "without projects" do
      it "returns a successful response" do
        get root_path
        expect(response).to be_successful
      end

      it "displays no projects message" do
        get root_path
        expect(response.body).to include("No projects yet")
      end
    end
  end
end