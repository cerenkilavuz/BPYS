class AllowedStudent < ApplicationRecord
    validates :student_number, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
    validates :surname, presence: true
  end
  