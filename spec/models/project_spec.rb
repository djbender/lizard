require "rails_helper"

RSpec.describe Project, type: :model do
  describe "associations" do
    it "has many test runs" do
      expect(Project.new).to respond_to(:test_runs)
    end

    it "destroys associated test runs when deleted" do
      project = Project.create!(name: "Test Project")
      test_run = project.test_runs.create!(
        branch: "main",
        coverage: 85.5,
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.2,
        ran_at: Time.current
      )
      
      expect { project.destroy! }.to change(TestRun, :count).by(-1)
    end
  end

  describe "validations" do
    it "is valid with a name" do
      project = Project.new(name: "Test Project")
      expect(project).to be_valid
    end

    it "requires a name" do
      project = Project.new(name: nil)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end
  end

  describe "api_key generation" do
    it "generates api_key automatically on create" do
      project = Project.create!(name: "Test Project")
      expect(project.api_key).to be_present
      expect(project.api_key.length).to eq(64) # 32 bytes hex = 64 chars
    end

    it "does not overwrite existing api_key" do
      existing_key = "existing_key_123"
      project = Project.new(name: "Test Project", api_key: existing_key)
      project.save!
      expect(project.api_key).to eq(existing_key)
    end
  end
end
