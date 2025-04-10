class GroupMembership < ApplicationRecord
  belongs_to :group
  
  belongs_to :student, class_name: "User"

  # Öğrenci sadece bir gruba üye olabilir
  validates :student_id, uniqueness: { message: "Zaten bir gruba üyesiniz." }
end
