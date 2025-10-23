require "rails_helper"

RSpec.describe "TestRuns", type: :request do
  let!(:project) { Project.create!(name: "Test Project") }
  let!(:test_run) do
    project.test_runs.create!(
      branch: "main",
      commit_sha: "abc123",
      ruby_specs: 100,
      js_specs: 50,
      coverage: 95.5,
      runtime: 30.5,
      ran_at: 1.hour.ago
    )
  end

  describe "DELETE /projects/:project_id/test_runs/:id" do
    it "deletes the test run" do
      expect {
        delete project_test_run_path(project, test_run)
      }.to change(TestRun, :count).by(-1)
    end

    it "redirects to the project page" do
      delete project_test_run_path(project, test_run)
      expect(response).to redirect_to(project_path(project))
    end

    it "sets a success flash notice" do
      delete project_test_run_path(project, test_run)
      expect(flash[:notice]).to eq("Test run was successfully deleted.")
    end

    context "when test run does not exist" do
      it "returns not found status" do
        delete project_test_run_path(project, 99999)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when test run belongs to a different project" do
      let!(:other_project) { Project.create!(name: "Other Project") }
      let!(:other_test_run) do
        other_project.test_runs.create!(
          branch: "feature",
          commit_sha: "def456",
          ruby_specs: 50,
          js_specs: 25,
          coverage: 80.0,
          runtime: 20.0,
          ran_at: 2.hours.ago
        )
      end

      it "returns not found status" do
        delete project_test_run_path(project, other_test_run)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
