class Student::ProjectRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_group

  
  def new
    if @group.nil?
      redirect_to student_projects_path, alert: "Projeye başvurmak için bir gruba üye olmalısınız."
    elsif @group.leader != current_user
      redirect_to published_student_projects_path, alert: "Sadece grup lideri başvuru yapabilir."
    elsif ProjectRequest.exists?(group: @group, project: @project)
      redirect_to published_student_projects_path, alert: "Bu projeye zaten başvurdunuz."
    else
      @request = ProjectRequest.new
      render "student/projects/project_requests/new"
      
    end
  end
 

  def create
    if @group.nil?
      redirect_to published_student_projects_path, alert: "Projeye başvurmak için bir gruba üye olmalısınız."
    elsif @group.leader != current_user
      redirect_to published_student_projects_path, alert: "Sadece grup lideri başvuru yapabilir."
    elsif ProjectRequest.exists?(group: @group, project: @project)
      redirect_to published_student_projects_path, alert: "Bu projeye zaten başvurdunuz."
    else
      @request = ProjectRequest.new(project: @project, group: @group)
      if @request.save
        redirect_to published_student_projects_path, notice: "Proje başvurusu başarıyla yapıldı."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def set_project
    Rails.logger.info "DEBUG: Gelen params => #{params.inspect}"
    
    if params[:project_id].blank?
      Rails.logger.error "HATA: project_id parametresi eksik!"
      redirect_to published_student_projects_path, alert: "Projeye başvururken hata oluştu. Lütfen tekrar deneyin." and return
    end
  
    @project = Project.find_by(id: params[:project_id])
  
    if @project.nil?
      Rails.logger.error "HATA: project_id (#{params[:project_id]}) ile eşleşen proje bulunamadı!"
      redirect_to published_student_projects_path, alert: "Geçersiz proje seçildi." and return
    end
  end



  def set_group
    @group = current_user.group
  end
end
