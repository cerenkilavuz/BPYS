class CreateGroupMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :group_memberships do |t|
      t.integer :group_id
      t.integer :student_id

      t.timestamps
    end
  end
end
