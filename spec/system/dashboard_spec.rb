require "rails_helper"
require "rake"

RSpec.describe "Dashboard", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "visiting the front page" do
    it "displays the dashboard page" do
      visit root_path

      aggregate_failures do
        expect(page).to have_content("🦎 Lizard")
        expect(page).to have_button("Generate Sample Data")
      end
    end

    it "shows no projects message when no projects exist" do
      visit root_path

      aggregate_failures do
        expect(page).to have_content("No projects yet")
        expect(page).to have_content("Create your first project to start tracking test metrics")
        expect(page).to have_link("Create Project", href: new_project_path)
      end
    end

    it "displays projects when they exist" do
      project = Project.create!(name: "Test Project")
      project.test_runs.create!(
        branch: "main",
        coverage: 85.0,
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.0,
        ran_at: 1.hour.ago
      )

      visit root_path

      aggregate_failures do
        expect(page).to have_content("Test Project")
        expect(page).to have_content("85.0%")
        expect(page).to have_content("Ruby Specs 100")
        expect(page).to have_content("JS Specs 50")
        expect(page).to have_content("Runtime 30s")
        expect(page).to have_content("Recent Activity")
      end
    end
  end

  describe "sample data buttons" do
    it "shows both generate and clear sample data buttons" do
      visit root_path

      aggregate_failures do
        expect(page).to have_button("Generate Sample Data")
        expect(page).to have_button("Clear Sample Data")
      end
    end

    it "generates sample data when generate button is clicked" do
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).and_return(double(invoke: nil, reenable: nil))
      allow(Rake::Task).to receive(:task_defined?).and_return(true)

      visit root_path
      click_button "Generate Sample Data"

      aggregate_failures do
        expect(page).to have_content("Sample data generated successfully!")
        expect(page).to have_current_path(root_path)
      end
    end

    it "clears sample data when clear button is clicked" do
      allow(Rails.application).to receive(:load_tasks)
      allow(Rake::Task).to receive(:[]).and_return(double(invoke: nil, reenable: nil))
      allow(Rake::Task).to receive(:task_defined?).and_return(true)

      visit root_path
      click_button "Clear Sample Data"

      aggregate_failures do
        expect(page).to have_content("Sample data cleared successfully!")
        expect(page).to have_current_path(root_path)
      end
    end
  end
end
