class RemoveGroupIdFromProjects < ActiveRecord::Migration[7.1]
  def change
    remove_column :projects, :group_id, :integer
  end
end
