module ProjectsHelper
  def run_count_for_project(project)
    @project_run_counts[project.id]
  end

  def latest_run_for_project(project)
    project.test_runs.order(ran_at: :desc).first
  end
end