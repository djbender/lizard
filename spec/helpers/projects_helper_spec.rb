require "rails_helper"

RSpec.describe ProjectsHelper, type: :helper do
  let!(:project) { Project.create!(name: "Test Project") }
  let!(:test_run1) { project.test_runs.create!(branch: "main", coverage: 85.0, ruby_specs: 100, js_specs: 50, runtime: 30.0, ran_at: 2.days.ago) }
  let!(:test_run2) { project.test_runs.create!(branch: "feature", coverage: 90.0, ruby_specs: 110, js_specs: 55, runtime: 25.0, ran_at: 1.day.ago) }

  before do
    # Set up the project run counts as the controller would
    @project_run_counts = {project.id => 2}
  end

  describe "#run_count_for_project" do
    it "returns the cached run count for a project" do
      expect(helper.run_count_for_project(project)).to eq(2)
    end

    it "returns nil for uncached project" do
      other_project = Project.create!(name: "Other Project")
      expect(helper.run_count_for_project(other_project)).to be_nil
    end
  end

  describe "#latest_run_for_project" do
    it "returns the most recent test run for a project" do
      latest_run = helper.latest_run_for_project(project)
      expect(latest_run).to eq(test_run2)
      expect(latest_run.ran_at).to be > test_run1.ran_at
    end

    it "returns nil for project with no test runs" do
      empty_project = Project.create!(name: "Empty Project")
      expect(helper.latest_run_for_project(empty_project)).to be_nil
    end
  end
end
