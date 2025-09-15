require "rails_helper"
require "rake"

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
        expect(response.body).to include("🦎 Lizard")
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

  describe "POST /generate_sample_data" do
    it "invokes the sample data rake task" do
      task_double = double
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("sample_data:generate").and_return(task_double)
      allow(Rake::Task).to receive(:task_defined?).with("sample_data:generate").and_return(true)
      expect(task_double).to receive(:invoke)
      expect(task_double).to receive(:reenable)

      post generate_sample_data_path

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Sample data generated successfully!")
    end

    it "handles rake task errors gracefully" do
      task_double = double
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("sample_data:generate").and_return(task_double)
      allow(task_double).to receive(:invoke).and_raise(StandardError.new("Test error"))
      allow(task_double).to receive(:reenable)
      allow(Rake::Task).to receive(:task_defined?).with("sample_data:generate").and_return(true)

      post generate_sample_data_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Error generating sample data: Test error")
    end

    it "always reenables the rake task" do
      task_double = double
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("sample_data:generate").and_return(task_double)
      allow(task_double).to receive(:invoke)
      allow(Rake::Task).to receive(:task_defined?).with("sample_data:generate").and_return(true)
      expect(task_double).to receive(:reenable)

      post generate_sample_data_path
    end

    it "handles task variable being nil when load_tasks fails" do
      allow(Rails.application).to receive(:load_tasks).and_raise(StandardError.new("Load tasks error"))

      post generate_sample_data_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Error generating sample data: Load tasks error")
    end
  end

  describe "POST /clear_sample_data" do
    it "invokes the clear sample data rake task" do
      task_double = double
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("sample_data:clear").and_return(task_double)
      allow(Rake::Task).to receive(:task_defined?).with("sample_data:clear").and_return(true)
      expect(task_double).to receive(:invoke)
      expect(task_double).to receive(:reenable)

      post clear_sample_data_path

      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Sample data cleared successfully!")
    end

    it "handles rake task errors gracefully" do
      task_double = double
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("sample_data:clear").and_return(task_double)
      allow(task_double).to receive(:invoke).and_raise(StandardError.new("Clear error"))
      allow(task_double).to receive(:reenable)
      allow(Rake::Task).to receive(:task_defined?).with("sample_data:clear").and_return(true)

      post clear_sample_data_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Error clearing sample data: Clear error")
    end

    it "always reenables the rake task" do
      task_double = double
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).with("sample_data:clear").and_return(task_double)
      allow(task_double).to receive(:invoke)
      allow(Rake::Task).to receive(:task_defined?).with("sample_data:clear").and_return(true)
      expect(task_double).to receive(:reenable)

      post clear_sample_data_path
    end

    it "handles task variable being nil when load_tasks fails" do
      allow(Rails.application).to receive(:load_tasks).and_raise(StandardError.new("Load tasks error"))

      post clear_sample_data_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Error clearing sample data: Load tasks error")
    end
  end
end
