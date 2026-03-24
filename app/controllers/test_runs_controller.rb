class TestRunsController < ApplicationController
  before_action :set_project

  def destroy
    @test_run = @project.test_runs.find(params[:id])
    @test_run.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@test_run),
          turbo_stream.update("flash-messages",
            "<div class=\"success\">Test run was successfully deleted.</div>")
        ]
      end
      format.html { redirect_to project_path(@project), notice: "Test run was successfully deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
