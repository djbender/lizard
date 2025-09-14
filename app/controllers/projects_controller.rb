class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(test_runs: []).all
    @project_run_counts = Hash[@projects.map { |p| [p.id, p.test_runs.count] }]
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @project = Project.find(params[:id])
    @recent_runs = @project.test_runs.order(ran_at: :desc).limit(10)
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def metrics
    @project = Project.find(params[:id])
    days = params[:days]&.to_i || 30

    @test_runs = @project.test_runs
      .where("ran_at > ?", days.days.ago)
      .order(:ran_at)

    render json: {
      labels: @test_runs.map { |r| r.ran_at.strftime("%m/%d %H:%M") },
      datasets: [
        {
          label: "Coverage %",
          data: @test_runs.map(&:coverage),
          borderColor: "rgb(75, 192, 192)",
          yAxisID: "y"
        },
        {
          label: "Total Specs",
          data: @test_runs.map { |r| r.ruby_specs + r.js_specs },
          borderColor: "rgb(255, 99, 132)",
          yAxisID: "y1"
        },
        {
          label: "Runtime (seconds)",
          data: @test_runs.map(&:runtime),
          borderColor: "rgb(255, 205, 86)",
          yAxisID: "y2"
        }
      ]
    }
  end

  private

  def project_params
    params.require(:project).permit(:name)
  end
end
