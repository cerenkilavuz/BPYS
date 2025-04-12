class AddProjectIdToGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :groups, :project_id, :integer
    add_index :groups, :project_id
    add_foreign_key :groups, :projects
  end
end
