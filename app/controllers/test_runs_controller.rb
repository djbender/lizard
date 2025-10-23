class TestRunsController < ApplicationController
  before_action :set_project

  def destroy
    @test_run = @project.test_runs.find(params[:id])
    @test_run.destroy!

    redirect_to project_path(@project), notice: "Test run was successfully deleted."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
