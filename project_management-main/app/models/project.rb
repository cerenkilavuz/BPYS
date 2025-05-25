
class Project < ApplicationRecord
  belongs_to :advisor, class_name: 'User', foreign_key: 'advisor_id'
  has_many :project_requests, dependent: :destroy
  has_many :groups, foreign_key: :project_id, dependent: :nullify
  
  validates :title, presence: true
  validates :description, presence: true
  validates :quota, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true 

  after_initialize :set_default_published, if: :new_record?

  def current_application_count
    accepted_group_ids = Group.where(project_id: id).pluck(:id)
    pending_requests = project_requests.where(status: [:pending]).count
  
    pending_requests + accepted_group_ids.count
  end

  def full?
    quota.present? && current_application_count >= quota
  end
  private

  def set_default_published
    self.published ||= true
  end
end

