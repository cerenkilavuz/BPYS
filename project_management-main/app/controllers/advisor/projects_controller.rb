module Advisor
  class ProjectsController < ApplicationController
    layout "advisor"
    before_action :authenticate_user!  
    before_action :only_advisors       
    before_action :set_project, only: [:edit, :update, :destroy]

    def dashboard
    end

    def requests
      @requests = ProjectRequest.joins(:project).where(status: 'pending', projects: { advisor_id: current_user.id })

    end
    
  
    def manage
      @projects = Project.where(advisor_id: current_user.id)  
    end
    

    def new
      @project = Project.new
    end

    
    def create
      @project = Project.new(project_params)
      @project.advisor_id = current_user.id  
      @project.published = true 
      if @project.save
        redirect_to advisor_projects_manage_path, notice: "Proje başarıyla eklendi."
      else
        render :new
      end
    end
    
  
    def edit
    end

    def update
      if @project.update(project_params)
        redirect_to advisor_projects_manage_path, notice: "Proje başarıyla güncellendi!"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    def destroy
      @project.groups.update_all(project_id: nil)
      ProjectRequest.where(project_id: @project.id).destroy_all
      ProjectProposal.where(project_id: @project.id).destroy_all
      @project.destroy
      redirect_to advisor_projects_manage_path, notice: "Proje başarıyla silindi!"
    end

    private

    def only_advisors
      unless current_user&.advisor?
        redirect_to root_path, alert: "Bu sayfaya erişim yetkiniz yok!"
      end
    end

    def set_project
      @project = Project.find_by(id: params[:id], advisor_id: current_user.id)
      redirect_to advisor_projects_manage_path, alert: "Bu projeye erişim yetkiniz yok!" unless @project
    end

    def project_params
      params.require(:project).permit(:title, :description, :quota)
    end
  end
end
