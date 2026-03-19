require "rails_helper"

RSpec.describe TestRunDecorator do
  let(:project) { Project.create!(name: "Test Project") }

  context "when all fields are present" do
    let(:run) { project.test_runs.create!(ran_at: 1.day.ago, branch: "main", runtime: 30.0, ruby_specs: 10, js_specs: 5, coverage: 85.0, commit_sha: "abc123") }

    before { ActiveDecorator::Decorator.instance.decorate(run) }

    it "returns the underlying values" do
      expect(run.branch).to eq("main")
      expect(run.runtime).to eq(30.0)
      expect(run.ruby_specs).to eq(10)
      expect(run.js_specs).to eq(5)
      expect(run.coverage).to eq(85.0)
      expect(run.commit_sha).to eq("abc123")
      expect(run.ran_at).to be_within(1.second).of(1.day.ago)
    end
  end

  context "when all fields are nil" do
    let(:run) { project.test_runs.create! }

    before { ActiveDecorator::Decorator.instance.decorate(run) }

    it "returns defaults" do
      expect(run.ran_at).to be_within(1.second).of(Time.current)
      expect(run.branch).to eq("unknown")
      expect(run.runtime).to eq(0.0)
      expect(run.ruby_specs).to eq(0)
      expect(run.js_specs).to eq(0)
      expect(run.coverage).to eq(0.0)
      expect(run.commit_sha).to eq("unknown")
    end
  end
end
