module Admin
    class ProjectSettingsController < ApplicationController
      layout 'admin'
      before_action :authenticate_user!
      before_action :require_admin
  
      def edit
        @deadline = SystemSetting.find_or_initialize_by(key: 'project_selection_deadline')
        @groups_with_projects = groups_with_projects(@deadline.value_as_date)
        @groups_without_project = groups_without_project(@deadline.value_as_date)
      end
  
      def update
        @deadline = SystemSetting.find_or_initialize_by(key: 'project_selection_deadline')
        if @deadline.update(value: params[:system_setting][:value])
          redirect_to edit_admin_project_setting_path, notice: "Proje seçim son tarihi güncellendi."
        else
          render :edit
        end
      end
  
      def assign_random_projects
        deadline = SystemSetting.find_by(key: 'project_selection_deadline')&.value_as_date
        return redirect_to edit_admin_project_setting_path, alert: "Proje seçim tarihi belirlenmemiş." unless deadline
  
        groups = groups_without_project(deadline)
        return redirect_to edit_admin_project_setting_path, alert: "Proje seçimi yapmamış grup bulunmamaktadır." if groups.empty?
  
        used_project_ids = Group.where.not(project_id: nil).pluck(:project_id)
        available_projects = Project.where.not(id: used_project_ids)
  
        groups.each do |group|
          project = available_projects.sample
          if project
            group.update(project: project)
            available_projects = available_projects.where.not(id: project.id)
          end
        end
  
        redirect_to edit_admin_project_setting_path, notice: "Rastgele projeler başarıyla atandı."
      end
  
      private
  
      def system_setting_params
        params.require(:system_setting).permit(:value)
      end
  
      def groups_with_projects(deadline)
        Group.includes(:project, :project_proposals)
             .where('groups.created_at <= ?', deadline.end_of_day)
             .select do |group|
               group.project.present? || group.project_proposals.any? { |p| p.status == 'accepted' }
             end
      end
      
  
      def groups_without_project(deadline)
        Group.includes(:project, :project_proposals)
             .where('groups.created_at <= ?', deadline.end_of_day)
             .select do |group|
               group.project.blank? && group.project_proposals.none? { |p| p.status == 'accepted' }
             end
      end
      
  
      def require_admin
        redirect_to root_path unless current_user.admin?
      end
    end
  end
  