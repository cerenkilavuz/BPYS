
class ProjectRequest < ApplicationRecord
  belongs_to :project
  belongs_to :group

  validates :project_id, uniqueness: { scope: :group_id, message: "Bu proje için zaten başvurunuz var." }
end
