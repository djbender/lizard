class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :slug
      t.string :api_key

      t.timestamps
    end
    add_index :projects, :slug, unique: true
    add_index :projects, :api_key, unique: true
  end
end
