class Group < ApplicationRecord
  belongs_to :leader, class_name: "User"
  has_many :group_memberships, dependent: :destroy
  has_many :students, through: :group_memberships, source: :student
  belongs_to :project , optional: true
  has_many :project_proposals, dependent: :destroy
  has_many :project_requests, dependent: :destroy

  validate :within_group_creation_deadline, on: :create
  validate :within_project_selection_deadline, on: :update

def within_group_creation_deadline
  return if Current.user&.admin?

  deadline_str = SystemSetting.find_by(key: 'group_creation_deadline')
  deadline = deadline_str&.value_as_date
  if deadline.present? && Date.today > deadline
    errors.add(:base, "Grup oluşturma süresi dolmuştur.")
  end
end


def within_project_selection_deadline
  return if Current.user&.admin?

  if project_id_changed? && project_id.present?
    deadline_str = SystemSetting.find_by(key: 'project_selection_deadline')
    deadline = deadline_str&.value_as_date
    if deadline.present? && Date.today > deadline
      errors.add(:base, "Proje seçme süresi dolmuştur.")
    end
  end
end
  

end
