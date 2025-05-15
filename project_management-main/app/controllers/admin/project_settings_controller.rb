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
      
        # Tüm projeleri kontenjan ve atanmış grup sayısıyla birlikte al
        project_slots = Project.includes(:groups).map do |project|
          max_quota = project.quota || 0
          assigned = project.groups.count
          remaining = max_quota - assigned
          [project, remaining]
        end.select { |_, remaining| remaining > 0 }
      
        if project_slots.empty?
          return redirect_to edit_admin_project_setting_path, alert: "Hiçbir projede boş kontenjan bulunmamaktadır."
        end
      
        # Grupları sırasıyla projelere ata
        groups.each do |group|
          # İlk boş kontenjanı olan projeyi bul
          project_with_slot = project_slots.find { |_, remaining| remaining > 0 }
          break unless project_with_slot
      
          project, remaining = project_with_slot
          group.update(project: project)
          project_with_slot[1] -= 1 # Kontenjanı güncelle
        end
      
        redirect_to edit_admin_project_setting_path, notice: "Projeler başarıyla atandı."
      end
      
  
      private
  
      def system_setting_params
        params.require(:system_setting).permit(:value)
      end
  
      def groups_with_projects(deadline)
        Group.where.not(project_id: nil)
             .where('created_at <= ?', deadline.end_of_day)
      end
      
      def groups_without_project(deadline)
        Group.where(project_id: nil)
             .where('created_at <= ?', deadline.end_of_day)
      end
          
  
      def require_admin
        redirect_to root_path unless current_user.admin?
      end
    end
  end
  