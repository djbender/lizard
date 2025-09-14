class RemoveDescriptionFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :description, :string
  end
end
