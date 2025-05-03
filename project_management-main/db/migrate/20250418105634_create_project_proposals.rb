class CreateProjectProposals < ActiveRecord::Migration[7.1]
  def change
    create_table :project_proposals do |t|
      t.integer :group_id, null: false
      t.integer :advisor_id, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0

      t.timestamps
    end

    add_foreign_key :project_proposals, :users, column: :group_id
    add_foreign_key :project_proposals, :users, column: :advisor_id
  end
end
