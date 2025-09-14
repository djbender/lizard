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

    it 'generates test runs with realistic data ranges' do
      Rake::Task['sample_data:generate'].invoke
      
      project = Project.find_by(name: 'Test Project')
      test_runs = project.test_runs
      
      expect(test_runs.count).to eq(30)
      
      aggregate_failures do
        expect(test_runs.minimum(:coverage)).to be >= 0
        expect(test_runs.maximum(:coverage)).to be <= 100
        expect(test_runs.minimum(:ruby_specs)).to be >= 60  # 80 - 20 for bad runs
        expect(test_runs.maximum(:ruby_specs)).to be <= 120
        expect(test_runs.minimum(:js_specs)).to be >= 30
        expect(test_runs.maximum(:js_specs)).to be <= 60
        expect(test_runs.minimum(:runtime)).to be >= 20.0
        expect(test_runs.maximum(:runtime)).to be <= 80.0   # 60 + 20 for bad runs
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