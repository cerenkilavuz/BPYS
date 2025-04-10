class AddGroupIdToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :group_id, :integer
    add_foreign_key :projects, :groups
    add_index :projects, :group_id
  end
end
