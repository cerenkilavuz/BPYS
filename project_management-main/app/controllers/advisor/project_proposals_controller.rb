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
      ActiveRecord::Base.transaction do
        # Yeni proje oluştur
        project = Project.create!(
          title: @project_proposal.title,
          description: @project_proposal.description,
          advisor_id: current_user.id,  # veya başka bir şekilde atanıyorsa düzenle
          quota: 1 # İsteğe bağlı, varsayılan olarak 1 grup için ayarlanabilir
        )
    
        # Gruba projeyi ata
        @project_proposal.group.update!(project: project)
    
        # Teklifi kabul edilmiş olarak işaretle
        @project_proposal.update!(status: :accepted)
      end
    
      redirect_to advisor_project_proposals_path, notice: "Proje teklifi kabul edildi ve proje oluşturuldu."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to advisor_project_proposals_path, alert: "Proje oluşturulurken bir hata oluştu: #{e.message}"
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
  