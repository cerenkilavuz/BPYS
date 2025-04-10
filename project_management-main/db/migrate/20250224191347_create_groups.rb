class CreateGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :leader_id

      t.timestamps
    end
  end
end
