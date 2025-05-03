class ProjectProposal < ApplicationRecord
    belongs_to :group ,class_name: 'Group'
    belongs_to :advisor, class_name: 'User'
    # model/project_proposal.rb
    scope :accepted, -> { where(status: 1) }

    enum status: { pending: 0, accepted: 1, rejected: 2 }
  
    validates :title, :description, presence: true
  end