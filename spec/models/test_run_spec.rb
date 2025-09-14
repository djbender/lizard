require "rails_helper"

RSpec.describe TestRun, type: :model do
  let(:project) { Project.create!(name: "Test Project") }
  
  describe "associations" do
    it "belongs to project" do
      expect(TestRun.new).to respond_to(:project)
    end

    it "requires a project" do
      test_run = TestRun.new(
        branch: "main",
        coverage: 85.5,
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.2,
        ran_at: Time.current
      )
      expect(test_run).not_to be_valid
      expect(test_run.errors[:project]).to include("must exist")
    end
  end

  describe "validations" do
    it "is valid with all required attributes" do
      test_run = TestRun.new(
        project: project,
        branch: "main",
        coverage: 85.5,
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.2,
        ran_at: Time.current
      )
      expect(test_run).to be_valid
    end
  end
end
