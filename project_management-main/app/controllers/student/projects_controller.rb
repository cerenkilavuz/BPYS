module Student
  class ProjectsController < ApplicationController
    before_action :authenticate_user! 
    layout "student"

    def index
      @group = current_user.group
    end

    def published
      excluded_project_ids = ProjectProposal.where.not(project_id: nil).pluck(:project_id)
      @projects = Project.includes(:advisor, :project_requests, :groups)
                         .where(published: true)
                         .where.not(id: excluded_project_ids)
      @group = current_user.group
    end
    

    def proposals
      if current_user.group.nil?
        redirect_to student_projects_path, alert: "Henüz bir gruba atanmadınız." and return
      end
    
      @project_proposals = ProjectProposal.where(group_id: current_user.group.id)
    end
    
    
  end
end
