class ProjectApplication < ApplicationRecord
  
  belongs_to :user  # Başvuruyu yapan öğrenci
  belongs_to :project  # Başvurulan proje

  enum status: { pending: 0, accepted: 1, rejected: 2 }
end
