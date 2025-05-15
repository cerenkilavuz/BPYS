class User < ApplicationRecord
  validate :email_must_be_allowed_student, if: -> { role == "student" }

  enum role: { student: 0, advisor: 1, admin: 2 }  
  scope :students, -> { where(role: "student") }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :projects, foreign_key: "advisor_id"
  has_one :group_membership, foreign_key: "student_id", dependent: :destroy
  has_one :group, through: :group_membership
  has_many :owned_projects, class_name: "Project", foreign_key: "advisor_id"
  has_many :advised_proposals, class_name: 'ProjectProposal', foreign_key: 'advisor_id'
  has_many :project_proposals

  private

  def email_must_be_allowed_student
    if role == "student" && !AllowedStudent.exists?(email: email.downcase)
      errors.add(:email, "bu email ile kayıt olunamaz.")
    end
  end
  
end
