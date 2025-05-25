module Advisor
  class GroupsController < ApplicationController
    layout "advisor"
    before_action :authenticate_user!

    def index
      @groups = Group
        .includes(:leader, :students, :project) 
        .joins(:project)
        .where(projects: { advisor_id: current_user.id })
    end

    def destroy
      @group = Group.find(params[:id])
      current_project = @group.project
    
      project_request = ProjectRequest.find_by(group_id: @group.id, project_id: @group.project_id)
      project_proposal = ProjectProposal.find_by(group_id: @group.id, project_id: @group.project_id)
    
      if @group.update(project_id: nil)
        if project_request.present?
          project_request.destroy
        elsif project_proposal.present?
          project_proposal.destroy
          current_project.destroy if current_project.present?
        end        
        redirect_to advisor_groups_path, notice: "Grup silindi."
      else
        redirect_to advisor_groups_path, alert: "Grup silinirken bir hata oluştu."
      end
    end    
  end
end
