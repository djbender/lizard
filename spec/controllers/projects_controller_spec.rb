require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:valid_attributes) { {name: "Test Project"} }
  let(:invalid_attributes) { {name: ""} }
  let!(:project) { Project.create!(valid_attributes) }

  describe "GET /projects" do
    it "returns a successful response" do
      get projects_path
      expect(response).to be_successful
    end

    it "displays project names" do
      get projects_path
      expect(response.body).to include("Test Project")
    end
  end

  describe "GET /projects/:id" do
    let!(:test_run) { project.test_runs.create!(branch: "main", coverage: 85.0, ruby_specs: 100, js_specs: 50, runtime: 30.0, ran_at: 1.day.ago) }

    it "returns a successful response" do
      get project_path(project)
      expect(response).to be_successful
    end

    it "displays project details" do
      get project_path(project)
      expect(response.body).to include("Test Project")
      expect(response.body).to include("85.0%")
    end
  end

  describe "GET /projects/new" do
    it "returns a successful response" do
      get new_project_path
      expect(response).to be_successful
    end

    it "displays the form" do
      get new_project_path
      expect(response.body).to include("Create New Project")
    end
  end

  describe "GET /projects/:id/edit" do
    it "returns a successful response" do
      get edit_project_path(project)
      expect(response).to be_successful
    end

    it "displays the edit form" do
      get edit_project_path(project)
      expect(response.body).to include("Edit Project")
      expect(response.body).to include("Test Project")
    end
  end

  describe "POST /projects" do
    context "with valid params" do
      it "creates a new Project" do
        expect {
          post projects_path, params: {project: valid_attributes}
        }.to change(Project, :count).by(1)
      end

      it "redirects to the created project" do
        post projects_path, params: {project: valid_attributes}
        expect(response).to redirect_to(Project.last)
      end
    end

    context "with invalid params" do
      it "does not create a new Project" do
        expect {
          post projects_path, params: {project: invalid_attributes}
        }.not_to change(Project, :count)
      end

      it "returns unprocessable content status" do
        post projects_path, params: {project: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "displays validation errors" do
        post projects_path, params: {project: invalid_attributes}
        expect(response.body).to include("Name can&#39;t be blank")
      end
    end
  end

  describe "PATCH /projects/:id" do
    context "with valid params" do
      let(:new_attributes) { {name: "Updated Project Name"} }

      it "updates the requested project" do
        patch project_path(project), params: {project: new_attributes}
        project.reload
        expect(project.name).to eq("Updated Project Name")
      end

      it "redirects to the project" do
        patch project_path(project), params: {project: new_attributes}
        expect(response).to redirect_to(project)
      end
    end

    context "with invalid params" do
      it "returns unprocessable content status" do
        patch project_path(project), params: {project: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "displays validation errors" do
        patch project_path(project), params: {project: invalid_attributes}
        expect(response.body).to include("Name can&#39;t be blank")
      end
    end
  end

  describe "GET /projects/:id/metrics" do
    let!(:test_run1) { project.test_runs.create!(branch: "main", coverage: 85.0, ruby_specs: 100, js_specs: 50, runtime: 30.0, ran_at: 10.days.ago) }
    let!(:test_run2) { project.test_runs.create!(branch: "feature", coverage: 90.0, ruby_specs: 110, js_specs: 55, runtime: 25.0, ran_at: 5.days.ago) }

    it "returns JSON response" do
      get metrics_project_path(project)
      expect(response.content_type).to include("application/json")
    end

    it "returns metrics data" do
      get metrics_project_path(project)
      json_response = JSON.parse(response.body)

      expect(json_response).to have_key("labels")
      expect(json_response).to have_key("datasets")
      expect(json_response["datasets"].size).to eq(3)
    end

    it "filters by days parameter" do
      get metrics_project_path(project), params: {days: 7}
      json_response = JSON.parse(response.body)

      expect(json_response["labels"].size).to eq(1) # Only test_run2 within 7 days
    end
  end
end
