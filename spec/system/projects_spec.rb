require "rails_helper"

RSpec.describe "Projects", type: :system do
  describe "Project show page" do
    let!(:project) { Project.create!(name: "Test Project") }

    before do
      visit project_path(project)
    end

    it "displays project details" do
      expect(page).to have_content("Test Project")
      expect(page).to have_content("API Key:")
      expect(page).to have_content("Created:")
      expect(page).to have_content("Updated:")
    end

    describe "API key toggle functionality" do
      it "initially shows truncated API key" do
        within "#api-key-display" do
          expect(page).to have_content("#{project.api_key[0..10]}...")
        end

        expect(page).to have_css("#api-key-display", visible: true)
        expect(page).to have_css("#api-key-full", visible: false)
      end

      it "has click handlers and proper HTML structure for JavaScript functionality" do
        # Check that elements are set up correctly for JavaScript
        expect(page).to have_css('#api-key-display[onclick="toggleApiKey()"]')
        expect(page).to have_css('#api-key-full[onclick="toggleApiKey()"]', visible: :all)

        # Check the HTML structure supports the toggle
        expect(page).to have_css("#api-key-display", visible: true)
        expect(page).to have_css("#api-key-full", visible: false)

        # Verify the full API key is in the page HTML (even if hidden)
        expect(page.html).to include(project.api_key)
      end

      it "has appropriate cursor styling and tooltips" do
        expect(page).to have_css('#api-key-display[style*="cursor: pointer"]')
        expect(page).to have_css('#api-key-display[title="Click to reveal full API key"]')
        expect(page).to have_css('#api-key-full[title="Click to hide API key"]', visible: :all)
      end
    end

    describe "Recent test runs section" do
      context "when project has no test runs" do
        it "displays empty test runs table" do
          expect(page).to have_content("Recent Test Runs")
          expect(page).to have_css("table")
          expect(page).to have_content("Date")
          expect(page).to have_content("Branch")
          expect(page).to have_content("Ruby Specs")
        end
      end

      context "when project has test runs" do
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

        before do
          visit project_path(project)
        end

        it "displays test run data" do
          expect(page).to have_content("main")
          expect(page).to have_content("100")
          expect(page).to have_content("50")
          expect(page).to have_content("95.5%")
          expect(page).to have_content("30.5s")
        end

        it "displays a delete button for the test run" do
          expect(page).to have_button("Delete")
        end

        it "has confirmation prompt configured on delete button" do
          delete_button = page.find("button", text: "Delete")
          expect(delete_button["data-turbo-confirm"]).to eq("Are you sure you want to delete this test run?")
        end

        it "deletes the test run when delete button is clicked" do
          expect {
            click_button "Delete"
          }.to change(TestRun, :count).by(-1)
        end

        it "redirects to project page after deletion" do
          click_button "Delete"
          expect(page).to have_current_path(project_path(project))
        end

        it "displays a success notice after deletion" do
          click_button "Delete"
          expect(page).to have_content("Test run was successfully deleted.")
        end
      end

      context "with JavaScript enabled", :js do
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

        before do
          visit project_path(project)
        end

        it "shows confirmation dialog and deletes when accepted" do
          page.accept_confirm do
            click_button "Delete"
          end
          expect(page).to have_content("Test run was successfully deleted.")
        end

        it "shows confirmation dialog and does not delete when dismissed" do
          page.dismiss_confirm do
            click_button "Delete"
          end
          expect(TestRun.count).to eq(1)
        end
      end
    end
  end
end
