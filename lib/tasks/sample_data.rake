namespace :sample_data do
  desc "Generate fake test data for 'Test Project'"
  task generate: :environment do
    puts "🚀 Generating fake data for Test Project..." unless Rails.env.test?

    # Create or find the Test Project
    project = Project.find_or_create_by(name: "Test Project")
    puts "📁 Project: #{project.name} (ID: #{project.id})" unless Rails.env.test?
    puts "🔑 API Key: #{project.api_key}" unless Rails.env.test?

    # Generate 30 days of test run data
    30.times do |i|
      days_ago = i
      date = days_ago.days.ago
      
      # Create realistic test metrics with some variation
      base_coverage = 75 + rand(25)  # 75-100% coverage
      ruby_specs = 80 + rand(40)     # 80-120 Ruby specs
      js_specs = 30 + rand(30)       # 30-60 JS specs
      runtime = 20.0 + rand(40.0)    # 20-60 seconds runtime
      
      # Add some randomness - occasional drops in coverage/performance
      if rand(10) == 0  # 10% chance of a "bad" run
        base_coverage -= rand(20)
        runtime += rand(20.0)
      end
      
      # Vary branch names
      branches = ["main", "develop", "feature/user-auth", "feature/api-improvements", "hotfix/security-patch"]
      branch = branches.sample
      
      test_run = project.test_runs.create!(
        commit_sha: SecureRandom.hex(20),
        branch: branch,
        ruby_specs: ruby_specs,
        js_specs: js_specs,
        runtime: runtime.round(2),
        coverage: base_coverage.clamp(0, 100).round(1),
        ran_at: date
      )
      
      print "." unless Rails.env.test?
    end
    
    unless Rails.env.test?
      puts "\n✅ Generated #{project.test_runs.count} test runs for '#{project.name}'"
      puts "📊 Coverage range: #{project.test_runs.minimum(:coverage)}% - #{project.test_runs.maximum(:coverage)}%"
      puts "⏱️  Runtime range: #{project.test_runs.minimum(:runtime)}s - #{project.test_runs.maximum(:runtime).round(1)}s"
      puts "🧪 Total specs range: #{project.test_runs.minimum('ruby_specs + js_specs')} - #{project.test_runs.maximum('ruby_specs + js_specs')}"
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