require 'rails_helper'
require 'rake'

RSpec.describe 'sample_data rake tasks', type: :task do
  before(:all) do
    Rake.application.rake_require 'tasks/sample_data'
    Rake::Task.define_task(:environment)
  end

  before(:each) do
    Rake::Task['sample_data:generate'].reenable
    Rake::Task['sample_data:clear'].reenable
    Rake::Task['sample_data:reset'].reenable
  end

  describe 'sample_data:generate' do
    it 'creates Test Project if it does not exist' do
      expect { Rake::Task['sample_data:generate'].invoke }.to change(Project, :count).by(1)
      
      project = Project.find_by(name: 'Test Project')
      expect(project).to be_present
      expect(project.api_key).to be_present
    end

    it 'uses existing Test Project if it already exists' do
      existing_project = Project.create!(name: 'Test Project')
      
      expect { Rake::Task['sample_data:generate'].invoke }.not_to change(Project, :count)
      
      project = Project.find_by(name: 'Test Project')
      expect(project.id).to eq(existing_project.id)
    end

    it 'generates 30 test runs for Test Project' do
      project = Project.create!(name: 'Test Project')
      
      expect { Rake::Task['sample_data:generate'].invoke }.to change { project.test_runs.count }.by(30)
    end

    it 'generates test runs with realistic monotonic growth ranges' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      test_runs = project.test_runs
      
      expect(test_runs.count).to eq(30)
      
      aggregate_failures do
        expect(test_runs.minimum(:coverage)).to be >= 65.0
        expect(test_runs.maximum(:coverage)).to be <= 95.0
        expect(test_runs.minimum(:ruby_specs)).to be >= 50
        expect(test_runs.maximum(:ruby_specs)).to be <= 120
        expect(test_runs.minimum(:js_specs)).to be >= 20
        expect(test_runs.maximum(:js_specs)).to be <= 60
        expect(test_runs.minimum(:runtime)).to be >= 15.0
        expect(test_runs.maximum(:runtime)).to be <= 45.0
      end
    end

    it 'generates test runs with realistic monotonic growth over time' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      test_runs = project.test_runs.order(:ran_at)
      
      oldest_run = test_runs.first
      newest_run = test_runs.last
      
      aggregate_failures do
        # Coverage should grow from oldest to newest (project improves over time)
        expect(oldest_run.coverage).to be_within(1.0).of(65.0)
        expect(newest_run.coverage).to be_within(1.0).of(95.0)
        
        # Ruby specs should grow from oldest to newest (more tests added)
        expect(oldest_run.ruby_specs).to be_within(2).of(50)
        expect(newest_run.ruby_specs).to be_within(3).of(120)
        
        # JS specs should grow from oldest to newest (more frontend tests)
        expect(oldest_run.js_specs).to be_within(2).of(20)
        expect(newest_run.js_specs).to be_within(2).of(60)
        
        # Runtime should increase from oldest to newest (more tests = longer runtime)
        expect(oldest_run.runtime).to be_within(1.0).of(15.0)
        expect(newest_run.runtime).to be_within(1.0).of(45.0)
      end
    end

    it 'generates test runs with purely linear growth (no variations, no sine wave pattern)' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      test_runs = project.test_runs.order(:ran_at)
      
      # Check that the growth has very consistent absolute increments (linear growth)
      coverage_increments = []
      runtime_increments = []
      
      (0...test_runs.count - 1).each do |i|
        current = test_runs[i]
        next_run = test_runs[i + 1]
        
        coverage_increment = (next_run.coverage - current.coverage).round(2)
        runtime_increment = (next_run.runtime - current.runtime).round(2)
        
        coverage_increments << coverage_increment
        runtime_increments << runtime_increment
      end
      
      aggregate_failures do
        # Coverage should have very consistent absolute daily increments (linear growth)
        expect(coverage_increments.uniq.length).to be <= 3  # Should be only 1-2 different values due to rounding
        
        # Runtime should have very consistent absolute daily increments (linear growth)
        expect(runtime_increments.uniq.length).to be <= 3  # Should be only 1-2 different values due to rounding
        
        # Integer values (specs) may have small rounding variations but should be minimal
        ruby_changes = []
        js_changes = []
        (0...test_runs.count - 1).each do |i|
          current = test_runs[i]
          next_run = test_runs[i + 1]
          
          ruby_change = (next_run.ruby_specs - current.ruby_specs).abs
          js_change = (next_run.js_specs - current.js_specs).abs
          
          ruby_changes << ruby_change
          js_changes << js_change
        end
        
        # Should have very consistent increments (mostly 2-3 per day)
        expect(ruby_changes.max).to be <= 3  # Small consistent increments
        expect(js_changes.max).to be <= 2   # Small consistent increments
      end
    end

    it 'generates test runs with various branch names' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      branches = project.test_runs.pluck(:branch).uniq
      
      expect(branches).to include('main')
      expect(branches.length).to be > 1
    end

    it 'generates test runs with unique commit SHAs' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      commit_shas = project.test_runs.pluck(:commit_sha).uniq
      
      expect(commit_shas.length).to eq(30)
      commit_shas.each do |sha|
        expect(sha.length).to eq(40)  # SecureRandom.hex(20) = 40 chars
      end
    end

    it 'generates test runs with ran_at dates spanning 30 days' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      ran_at_dates = project.test_runs.pluck(:ran_at).sort
      
      expect(ran_at_dates.first).to be <= 29.days.ago
      expect(ran_at_dates.last).to be >= Time.current.beginning_of_day
    end

    it 'outputs progress and summary when not in test environment' do
      allow(Rails.env).to receive(:test?).and_return(false)
      
      expect { Rake::Task['sample_data:generate'].invoke }.to output(/🚀 Generating fake data for Test Project/).to_stdout
    end
  end

  describe 'sample_data:clear' do
    it 'removes all test runs for Test Project' do
      project = Project.create!(name: 'Test Project')
      project.test_runs.create!(
        branch: 'main',
        coverage: 85.0,
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.0,
        ran_at: Time.current
      )
      
      expect { Rake::Task['sample_data:clear'].invoke }.to change { project.test_runs.count }.from(1).to(0)
    end

    it 'does nothing if Test Project does not exist' do
      expect { Rake::Task['sample_data:clear'].invoke }.not_to raise_error
    end

    it 'outputs message when not in test environment' do
      allow(Rails.env).to receive(:test?).and_return(false)
      
      expect { Rake::Task['sample_data:clear'].invoke }.to output(/❌ 'Test Project' not found/).to_stdout
    end

    it 'outputs clear message when project exists and not in test environment' do
      project = Project.create!(name: 'Test Project')
      project.test_runs.create!(
        branch: 'main',
        coverage: 85.0,
        ruby_specs: 100,
        js_specs: 50,
        runtime: 30.0,
        ran_at: Time.current
      )
      
      allow(Rails.env).to receive(:test?).and_return(false)
      
      expect { Rake::Task['sample_data:clear'].invoke }.to output(/🗑️  Cleared 1 test runs for 'Test Project'/).to_stdout
    end

    it 'does not remove the Test Project itself' do
      project = Project.create!(name: 'Test Project')
      
      Rake::Task['sample_data:clear'].invoke
      
      expect(Project.find_by(name: 'Test Project')).to eq(project)
    end
  end

  describe 'sample_data:reset' do
    it 'clears existing data and generates new data' do
      project = Project.create!(name: 'Test Project')
      old_run = project.test_runs.create!(
        branch: 'old',
        coverage: 50.0,
        ruby_specs: 10,
        js_specs: 5,
        runtime: 10.0,
        ran_at: 1.year.ago
      )
      
      Rake::Task['sample_data:reset'].invoke
      
      expect(project.test_runs.count).to eq(30)
      expect(project.test_runs.find_by(id: old_run.id)).to be_nil
    end
  end
end