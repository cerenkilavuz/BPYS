class User < ApplicationRecord

  enum role: { student: 0, advisor: 1, admin: 2 }  # Roller belirlendi
  scope :students, -> { where(role: "student") }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, foreign_key: "advisor_id"
  has_one :group_membership, foreign_key: "student_id"
  has_one :group, through: :group_membership
  has_many :owned_projects, class_name: "Project", foreign_key: "advisor_id"
  
  

  
end
