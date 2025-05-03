
class ProjectRequest < ApplicationRecord
  belongs_to :project
  belongs_to :group, optional: true
  
  enum status: { pending: 0, accepted: 1, rejected: 2 }
  validates :project_id, uniqueness: { scope: :group_id, message: "Bu proje için zaten başvurunuz var." }
end
