class CreateTestRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :commit_sha
      t.string :branch
      t.integer :ruby_specs
      t.integer :js_specs
      t.float :runtime
      t.float :coverage
      t.datetime :ran_at

      t.timestamps
    end
  end
end
