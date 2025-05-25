# app/controllers/project_proposals_controller.rb
class Student::ProjectProposalsController < ApplicationController
    layout 'student'
    before_action :authenticate_user!
    before_action :set_group
  
    def new
      @project_proposal = ProjectProposal.new
      @advisors = User.where(role: :advisor)
    end
  
    def create
      @project_proposal = ProjectProposal.new(project_proposal_params)
      @project_proposal.group = @group
  
      if @project_proposal.save
        redirect_to proposals_student_projects_path, notice: 'Proje teklifi başarıyla gönderildi.'
      else
        @advisors = User.where(role: advisor)
        render :new, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_group
      @group = current_user.group
    end
  
    def project_proposal_params
      params.require(:project_proposal).permit(:advisor_id, :title, :description)
    end
  end
  