require "rspec/core/rake_task"

# Override the default spec:system task to explicitly include system tests
namespace :spec do
  # Clear the existing task
  Rake::Task["spec:system"].clear if Rake::Task.task_defined?("spec:system")

  desc "Run system specs"
  RSpec::Core::RakeTask.new(:system) do |t|
    t.pattern = "spec/system/**/*_spec.rb"
    t.rspec_opts = "--tag type:system"
    # Disable SimpleCov for system tests (they don't contribute meaningful coverage)
    ENV["SIMPLECOV_ENABLED"] = "false"
  end
end
