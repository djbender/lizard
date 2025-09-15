module Api
  module V1
    class TestRunsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_project!

      def create
        test_run = @project.test_runs.create!(test_run_params)
        render json: {status: "success", id: test_run.id}
      end

      private

      def authenticate_project!
        auth_header = request.headers["Authorization"]
        return render json: {error: "Missing Authorization header"}, status: :unauthorized unless auth_header

        api_key = auth_header.sub(/^Bearer\s+/, "")
        return render json: {error: "Invalid Authorization format"}, status: :unauthorized if api_key == auth_header

        @project = Project.find_by!(api_key: api_key)
      rescue ActiveRecord::RecordNotFound
        render json: {error: "Invalid API key"}, status: :unauthorized
      end

      def test_run_params
        params.require(:test_run).permit(
          :commit_sha, :branch, :ruby_specs, :js_specs,
          :runtime, :coverage, :ran_at
        )
      end
    end
  end
end
