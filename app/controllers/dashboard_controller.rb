# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  def index
    @projects = Project.includes(test_runs: []).all
    @recent_test_runs = TestRun.joins(:project)
                              .order(ran_at: :desc)
                              .limit(10)
                              .includes(:project)
    @project_run_counts = Hash[@projects.map { |p| [p.id, p.test_runs.count] }]
  end

end
