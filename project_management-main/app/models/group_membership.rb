class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :student, class_name: "User"

  validates :student_id, uniqueness: { message: "Zaten bir gruba üyesiniz." }
end
