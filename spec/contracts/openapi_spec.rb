require "rails_helper"
require "json_schemer"
require "yaml"

RSpec.describe "OpenAPI contract" do
  let(:spec) { YAML.load_file(Rails.root.join("public/api/v1/openapi.yaml")) }
  let(:schemas) { spec.dig("components", "schemas") }

  def schemer_for(schema_name)
    schema = schemas.fetch(schema_name)
    # Inline $ref resolution against components/schemas
    resolved = resolve_refs(schema)
    JSONSchemer.schema(resolved)
  end

  def resolve_refs(node)
    case node
    when Hash
      if node.key?("$ref")
        ref_name = node["$ref"].split("/").last
        resolve_refs(schemas.fetch(ref_name))
      else
        node.transform_values { |v| resolve_refs(v) }
      end
    when Array
      node.map { |v| resolve_refs(v) }
    else
      node
    end
  end

  describe "CreateTestRunRequest schema" do
    let(:schemer) { schemer_for("CreateTestRunRequest") }

    it "validates a full payload" do
      payload = {
        "test_run" => {
          "commit_sha" => "abc123def456",
          "branch" => "main",
          "ruby_specs" => 100,
          "js_specs" => 50,
          "runtime" => 30.5,
          "coverage" => 85.2,
          "ran_at" => "2026-03-23T12:00:00Z",
          "metadata" => {
            "github_run_id" => "23419710055",
            "github_repository" => "djbender/lizard-ruby"
          }
        }
      }

      expect(schemer.valid?(payload)).to be true
    end

    it "validates a minimal payload" do
      payload = {"test_run" => {}}

      expect(schemer.valid?(payload)).to be true
    end

    it "rejects missing test_run key" do
      expect(schemer.valid?({})).to be false
    end

    it "rejects unknown metadata keys" do
      payload = {
        "test_run" => {
          "metadata" => {"unknown_key" => "value"}
        }
      }

      expect(schemer.valid?(payload)).to be false
    end
  end

  describe "SuccessResponse schema" do
    let(:schemer) { schemer_for("SuccessResponse") }

    it "validates a success response" do
      response = {"status" => "success", "id" => 42}

      expect(schemer.valid?(response)).to be true
    end

    it "rejects response without id" do
      expect(schemer.valid?({"status" => "success"})).to be false
    end
  end

  describe "ErrorResponse schema" do
    let(:schemer) { schemer_for("ErrorResponse") }

    it "validates an error response" do
      response = {"error" => "Invalid API key"}

      expect(schemer.valid?(response)).to be true
    end

    it "rejects response without error" do
      expect(schemer.valid?({})).to be false
    end
  end

  describe "spec matches controller params" do
    let(:permitted_keys) { %w[commit_sha branch ruby_specs js_specs runtime coverage ran_at metadata] }
    let(:metadata_keys) { %w[github_run_id github_repository] }

    it "TestRunAttributes properties match test_run_params" do
      schema_keys = schemas.dig("TestRunAttributes", "properties").keys

      expect(schema_keys).to match_array(permitted_keys)
    end

    it "TestRunMetadata properties match metadata params" do
      metadata_ref = schemas.dig("TestRunAttributes", "properties", "metadata")
      metadata_schema_name = metadata_ref["$ref"].split("/").last
      metadata_schema_keys = schemas.dig(metadata_schema_name, "properties").keys

      expect(metadata_schema_keys).to match_array(metadata_keys)
    end
  end
end
