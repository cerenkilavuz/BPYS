class User < ApplicationRecord
  # Roller
  enum role: { student: 0, advisor: 1, admin: 2 }  
  scope :students, -> { where(role: "student") }

  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # İlişkiler
  has_many :projects, foreign_key: "advisor_id"
  has_one :group_membership, foreign_key: "student_id", dependent: :destroy
  has_one :group, through: :group_membership
  has_many :owned_projects, class_name: "Project", foreign_key: "advisor_id"
  has_many :advised_proposals, class_name: 'ProjectProposal', foreign_key: 'advisor_id'
  has_many :project_proposals

  # Validations
  validate :email_must_be_allowed_student, if: -> { student? }

  # Danışmanlar için sadece isim ve soyisim gerekli
  with_options if: :advisor? do
    validates :first_name, :last_name, presence: true
    validates :student_number, absence: true
  end

  # Admin için ekstra bilgi istenmiyor
  with_options if: :admin? do
    validates :first_name, :last_name, :student_number, absence: true
  end

  # Öğrencinin bilgilerini AllowedStudent tablosundan çek
  before_create :set_student_info_from_allowed_students, if: :student?

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def advisor_code
    full_name.split.map { |name| name[0] }.join.upcase
  end
  
  private

  def email_must_be_allowed_student
    unless AllowedStudent.exists?(email: email.downcase)
      errors.add(:email, "bu email ile kayıt olunamaz.")
    end
  end

  def set_student_info_from_allowed_students
    allowed = AllowedStudent.find_by(email: email.downcase)
    return unless allowed

    self.first_name = allowed.name
    self.last_name = allowed.surname
    self.student_number = allowed.student_number
  end
end
