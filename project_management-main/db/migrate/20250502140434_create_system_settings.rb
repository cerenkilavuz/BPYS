class CreateSystemSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :system_settings do |t|
      t.boolean :students_can_login, default: true
      t.boolean :students_can_register, default: true
      t.datetime :group_creation_deadline
      t.datetime :project_submission_deadline

      t.timestamps
    end
  end
end
