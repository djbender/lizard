class AddMetadataToTestRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :test_runs, :metadata, :jsonb, default: {}, null: false
  end
end
