class Advisor::ProjectProposalsController < ApplicationController
    layout 'advisor'
    before_action :authenticate_user!
    before_action :set_project_proposal, only: [:accept, :reject]
  
    # Danışmanın başvurularını listeleyeceğiz.
    def index
      @project_proposals = ProjectProposal.where(advisor_id: current_user.id)
    end
  
    # Kabul etme işlemi
    def accept
      @project_proposal.update(status: :accepted)
      redirect_to advisor_project_proposals_path, notice: "Proje teklifi kabul edildi."
    end
  
    # Reddetme işlemi
    def reject
      @project_proposal.update(status: :rejected)
      redirect_to advisor_project_proposals_path, notice: "Proje teklifi reddedildi."
    end
  
    private
  
    def set_project_proposal
      @project_proposal = ProjectProposal.find(params[:id])
    end
  end
  