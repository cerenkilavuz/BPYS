module Advisor
  class ProjectsController < ApplicationController
    before_action :authenticate_user!  # Kullanıcı giriş yapmalı
    before_action :only_advisors       # Sadece "advisor" erişebilir
    before_action :set_project, only: [:edit, :update, :destroy]

    # 1️⃣ "Projeler" ana ekranı
    def dashboard
    end

    # 2️⃣ "Öğrenci Teklifleri" sayfası

    def requests
      @requests = ProjectRequest.includes(:group, :project).where(project: current_user.owned_projects)
    end
    
    
    

    # 3️⃣ Proje yönetim sayfası
    def manage
      @projects = Project.where(advisor_id: current_user.id)  # Sadece giriş yapan danışmanın projelerini getir
    end
    

    # 4️⃣ Yeni proje ekleme
    def new
      @project = Project.new
    end

    
    def create
      @project = Project.new(project_params)
      @project.advisor_id = current_user.id  # Sadece danışman ekleyebilir
      @project.published = true  # Yeni eklenen projeyi otomatik yayınla
      if @project.save
        redirect_to advisor_projects_path, notice: "Proje başarıyla eklendi."
      else
        render :new
      end
    end
    
  

    # 5️⃣ Proje güncelleme
    def edit
    end

    def update
      if @project.update(project_params)
        redirect_to advisor_projects_manage_path, notice: "Proje başarıyla güncellendi!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # 6️⃣ Proje silme
    def destroy
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
