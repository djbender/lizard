namespace :sample_data do
  desc "Generate fake test data for 'Test Project'"
  task generate: :environment do
    puts "🚀 Generating fake data for Test Project..." unless Rails.env.test?

    # Create or find the Test Project
    project = Project.find_or_create_by(name: "Test Project")
    puts "📁 Project: #{project.name} (ID: #{project.id})" unless Rails.env.test?
    puts "🔑 API Key: #{project.api_key}" unless Rails.env.test?

    # Generate 30 days of test run data with smooth growth (max 3% daily change)
    # Starting values (oldest data)
    current_coverage = 65.0
    current_ruby_specs = 50
    current_js_specs = 20
    current_runtime = 15.0

    # Use linear growth with small random variations to avoid sine wave pattern
    target_coverage = 95.0
    target_ruby_specs = 120
    target_js_specs = 60
    target_runtime = 45.0

    # Calculate daily increments for linear growth
    coverage_daily_increment = (target_coverage - current_coverage) / 29.0
    ruby_daily_increment = (target_ruby_specs - current_ruby_specs) / 29.0
    js_daily_increment = (target_js_specs - current_js_specs) / 29.0
    runtime_daily_increment = (target_runtime - current_runtime) / 29.0

    # Track previous values to ensure monotonic growth (never goes down)
    prev_ruby_specs = current_ruby_specs
    prev_js_specs = current_js_specs

    30.times do |i|
      days_ago = 29 - i  # Start with oldest data (29 days ago) and work forward
      date = days_ago.days.ago

      # Apply pure linear growth (i: 0=oldest, 29=newest)
      progress = i  # 0 for oldest, 29 for newest

      # Calculate pure linear progression - no randomness at all
      base_coverage = current_coverage + (coverage_daily_increment * progress)
      runtime = current_runtime + (runtime_daily_increment * progress)

      # For integer values, calculate target and ensure they never decrease
      target_ruby = (current_ruby_specs + (ruby_daily_increment * progress)).round
      target_js = (current_js_specs + (js_daily_increment * progress)).round

      # Only allow increases or staying the same (never go down)
      if i == 0
        # First day uses starting values
        ruby_specs = current_ruby_specs
        js_specs = current_js_specs
      else
        ruby_specs = [target_ruby, prev_ruby_specs].max  # Never decrease
        js_specs = [target_js, prev_js_specs].max        # Never decrease
      end

      # Update previous values for next iteration
      prev_ruby_specs = ruby_specs
      prev_js_specs = js_specs

      # Vary branch names
      branches = ["main", "develop", "feature/user-auth", "feature/api-improvements", "hotfix/security-patch"]
      branch = branches.sample

      project.test_runs.create!(
        commit_sha: SecureRandom.hex(20),
        branch: branch,
        ruby_specs: ruby_specs,
        js_specs: js_specs,
        runtime: runtime.round(2),
        coverage: base_coverage.round(1),
        ran_at: date
      )

      print "." unless Rails.env.test?
    end

    unless Rails.env.test?
      puts "\n✅ Generated #{project.test_runs.count} test runs for '#{project.name}'"
      puts "📊 Coverage range: #{project.test_runs.minimum(:coverage)}% - #{project.test_runs.maximum(:coverage)}%"
      puts "⏱️  Runtime range: #{project.test_runs.minimum(:runtime)}s - #{project.test_runs.maximum(:runtime).round(1)}s"
      puts "🧪 Total specs range: #{project.test_runs.minimum("ruby_specs + js_specs")} - #{project.test_runs.maximum("ruby_specs + js_specs")}"
    end
  end

  desc "Clear all test data for 'Test Project'"
  task clear: :environment do
    project = Project.find_by(name: "Test Project")
    if project
      count = project.test_runs.count
      project.test_runs.destroy_all
      puts "🗑️  Cleared #{count} test runs for '#{project.name}'" unless Rails.env.test?
    else
      puts "❌ 'Test Project' not found" unless Rails.env.test?
    end
  end

  desc "Reset test data (clear and regenerate)"
  task reset: [:clear, :generate]
end
