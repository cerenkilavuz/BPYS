class CreateProjectRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :project_requests do |t|
      t.integer :group_id
      t.integer :project_id
      t.text :motivation
      t.string :status

      t.timestamps
    end
  end
end
