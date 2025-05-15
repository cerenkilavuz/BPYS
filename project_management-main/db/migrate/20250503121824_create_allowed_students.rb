class CreateAllowedStudents < ActiveRecord::Migration[7.1]
  def change
    create_table :allowed_students do |t|
      t.string :name
      t.string :surname
      t.string :student_number
      t.string :email

      t.timestamps
    end
  end
end
