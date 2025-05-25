class Advisor::ProjectProposalsController < ApplicationController
    layout 'advisor'
    before_action :authenticate_user!
    before_action :set_project_proposal, only: [:accept, :reject]
  
    def index
      @project_proposals = ProjectProposal.where(advisor_id: current_user.id)
    end
  
    def accept
      ActiveRecord::Base.transaction do
        project = Project.create!(
          title: @project_proposal.title,
          description: @project_proposal.description,
          advisor_id: current_user.id, 
          quota: 1 
        )
    
        @project_proposal.group.update!(project: project)
    
        @project_proposal.update!(status: :accepted, project_id: project.id)
      end
    
      redirect_to advisor_project_proposals_path, notice: "Proje teklifi kabul edildi."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to advisor_project_proposals_path, alert: "Proje oluşturulurken bir hata oluştu."
    end
    
  
    def reject
      @project_proposal.update(status: :rejected)
      redirect_to advisor_project_proposals_path, notice: "Proje teklifi reddedildi."
    end
  
    private
  
    def set_project_proposal
      @project_proposal = ProjectProposal.find(params[:id])
    end
  end
  