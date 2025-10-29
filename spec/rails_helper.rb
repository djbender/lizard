# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "capybara/playwright"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# Ensures that the test database schema matches the current schema file.
# If there are pending migrations it will invoke `db:test:prepare` to
# recreate the test database by loading the schema.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    :app,
    browser_type: :chromium,
    deviceScaleFactor: 2,
    headless: true,
    locale: "en-US",
    timezoneId: "America/Los_Angeles",
    viewport: {width: 1920, height: 1080},
    record_video_size: {width: 1920, height: 1080}
  )
end

Capybara.javascript_driver = :playwright

# Configure Capybara to save screenshots via save_path
Capybara.save_path = Rails.root.join("tmp/capybara/screenshots")

# Ensure video directory exists and clear old media (unless explicitly keeping them)
VIDEO_DIR = Rails.root.join("tmp/capybara/videos")
FileUtils.mkdir_p(VIDEO_DIR)
unless ENV["CAPYBARA_KEEP_ALL"] == "true"
  FileUtils.rm_f(Dir.glob(VIDEO_DIR.join("*.webm")))
  FileUtils.rm_f(Dir.glob(Capybara.save_path.join("*.png")))
end

if ENV["CAPYBARA_RECORD_ALL"] == "true"
  puts "\n🎥 CAPYBARA_RECORD_ALL enabled: saving videos for all system tests\n\n"
end

RSpec.configure do |config|
  # Save video recordings only for failed tests (or all tests if CAPYBARA_RECORD_ALL=true)
  config.before(:each, type: :system, js: true) do |example|
    # Register a callback that is invoked after the test completes and the browser context closes.
    # This callback is called during Capybara's reset_session! cleanup phase, after the video
    # has been finalized by Playwright. At this point, example.exception is already set if the
    # test failed, allowing us to conditionally save videos only for failures.
    #
    # Timeline:
    #   1. This callback is registered before the test runs
    #   2. Test executes
    #   3. Capybara calls reset_session!
    #   4. Browser context closes and video is finalized
    #   5. This callback is invoked with the video_path
    #   6. We check example.exception and save the video if present
    #      or always save if CAPYBARA_RECORD_ALL=true
    Capybara.current_session.driver.on_save_screenrecord do |video_path|
      record_all = ENV["CAPYBARA_RECORD_ALL"] == "true"

      if record_all || example.exception
        timestamp = Time.now.strftime("%Y%m%d-%H%M%S")
        safe_description = example.full_description.gsub(/[^0-9A-Za-z.-]/, "_")[0..100]
        saved_video = VIDEO_DIR.join("#{safe_description}-#{timestamp}.webm")

        begin
          FileUtils.cp(video_path, saved_video)
          puts "\n🎥 Video recording saved: #{saved_video}"
        rescue => e
          warn "\n⚠️  Failed to save video: #{e.message}"
        end
      end
    end
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Configure system tests to use Playwright for JavaScript tests
  config.before(:each, type: :system) do
    if RSpec.current_example.metadata[:js]
      driven_by :playwright
    else
      driven_by :rack_test
    end
  end

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/8-0/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
