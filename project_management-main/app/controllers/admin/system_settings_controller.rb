# app/controllers/admin/system_settings_controller.rb
class Admin::SystemSettingsController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :require_admin
  
    def edit
      @allowed_students = AllowedStudent.all
      @system_setting = SystemSetting.instance
    end
  
    def update
      @system_setting = SystemSetting.instance
      if @system_setting.update(system_setting_params)
        redirect_to edit_admin_system_setting_path, notice: "Sistem ayarları güncellendi."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    private
  
    def system_setting_params
      params.require(:system_setting).permit(
        :students_can_login,
        :students_can_register,
        :group_creation_deadline,
        :project_submission_deadline
      )
    end
  
    def require_admin
      redirect_to root_path, alert: "Yetkisiz erişim." unless current_user&.admin?
    end
  end
  