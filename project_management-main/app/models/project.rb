
class Project < ApplicationRecord
  belongs_to :advisor, class_name: 'User', foreign_key: 'advisor_id'
  has_many :project_requests
  belongs_to :group , optional: true
  
  validates :title, presence: true
  validates :description, presence: true
  validates :quota, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true 

  after_initialize :set_default_published, if: :new_record?

  def quota_full?
    quota.present? && project_requests.count >= quota
  end
  private

  def set_default_published
    self.published ||= true
  end
end

