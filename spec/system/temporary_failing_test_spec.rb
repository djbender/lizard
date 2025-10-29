require "rails_helper"

RSpec.describe "Temporary Failing Test", type: :system do
  describe "Video and screenshot capture verification", :js do
    let!(:project) { Project.create!(name: "Test Project for Video Capture") }

    before do
      visit project_path(project)
    end

    it "intentionally fails to trigger video and screenshot capture" do
      # This test intentionally fails to verify that:
      # 1. Videos are recorded for failing JS tests
      # 2. Screenshots are captured on failure
      # 3. Artifacts are uploaded to GitHub Actions
      #
      # TODO: Remove this test file after verifying CI artifacts work correctly

      expect(page).to have_content("Test Project for Video Capture")

      # Intentional failure to trigger screenshot and video capture
      expect(page).to have_content("THIS TEXT DOES NOT EXIST ON THE PAGE")
    end

    it "another intentional failure with interaction" do
      # Perform some interactions before failing to make the video more interesting
      expect(page).to have_content("Test Project for Video Capture")

      # Try to click something (this should work)
      expect(page).to have_css("#api-key-display")

      # Intentional failure
      expect(page).to have_button("Non-existent Button")
    end
  end
end
