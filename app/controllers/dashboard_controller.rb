# app/controllers/dashboard_controller.rb
require 'rake'

class DashboardController < ApplicationController
  def index
    @projects = Project.includes(test_runs: []).all
    @recent_test_runs = TestRun.joins(:project)
                              .order(ran_at: :desc)
                              .limit(10)
                              .includes(:project)
    @project_run_counts = Hash[@projects.map { |p| [p.id, p.test_runs.count] }]
  end

  def generate_sample_data
    begin
      Rake::Task.clear
      Rails.application.load_tasks
      Rake::Task['sample_data:generate'].invoke
      flash[:notice] = "Sample data generated successfully!"
    rescue => e
      flash[:alert] = "Error generating sample data: #{e.message}"
    end

    redirect_to root_path
  end

  def clear_sample_data
    begin
      Rake::Task.clear
      Rails.application.load_tasks
      Rake::Task['sample_data:clear'].invoke
      flash[:notice] = "Sample data cleared successfully!"
    rescue => e
      flash[:alert] = "Error clearing sample data: #{e.message}"
    end

    redirect_to root_path
  end

end
