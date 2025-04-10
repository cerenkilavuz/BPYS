class RemoveUserIdFromProjects < ActiveRecord::Migration[7.0]
  def change
    remove_column :projects, :user_id, :integer
    change_column_null :projects, :advisor_id, false
  end
end
