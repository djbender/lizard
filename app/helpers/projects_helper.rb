module ProjectsHelper
  def run_count_for_project(project)
    @project_run_counts[project.id]
  end

  def latest_run_for_project(project)
    project.test_runs.order(ran_at: :desc).first
  end

  def github_actions_url(metadata)
    repo = metadata["github_repository"]
    run_id = metadata["github_run_id"]
    return unless repo && run_id

    "https://github.com/#{repo}/actions/runs/#{run_id}"
  end
end
