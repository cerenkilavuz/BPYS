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
      
        # Danışman bazlı: { advisor_id => { projects: [[project, remaining]], group_count: n } }
        advisor_data = {}
      
        Project.includes(:groups, :advisor).each do |project|
          advisor = project.advisor
          next unless advisor && advisor.role == "advisor"
          
          max_quota = project.quota || 0
          assigned = project.groups.count
          remaining = max_quota - assigned
          next if remaining <= 0
      
          advisor_data[advisor.id] ||= { projects: [], group_count: 0 }
          advisor_data[advisor.id][:projects] << [project, remaining]
          advisor_data[advisor.id][:group_count] += assigned
        end
      
        return redirect_to edit_admin_project_setting_path, alert: "Hiçbir projede boş kontenjan bulunmamaktadır." if advisor_data.empty?
      
        # Grupları sırayla ata
        groups.each do |group|
          # En az gruba sahip danışmanı bul
          selected_advisor_id, advisor_info = advisor_data.min_by { |_, data| data[:group_count] }
      
          next unless advisor_info
      
          # Danışmanın boş kontenjanı olan bir projesini bul
          project_with_slot = advisor_info[:projects].find { |_, remaining| remaining > 0 }
      
          next unless project_with_slot
      
          project, remaining = project_with_slot
      
          group.update(project: project)
          project_with_slot[1] -= 1
          advisor_info[:group_count] += 1
      
          # Eğer bu projede kontenjan biterse, listeden çıkarmaya gerek yok çünkü find ile sadece kalanlara bakılıyor
        end
      
        redirect_to edit_admin_project_setting_path, notice: "Projeler danışmanlara dengeli şekilde atandı."
      end
      
      
      def rename_groups
        if Group.where(project_id: nil).exists?
          redirect_to admin_projects_path, alert: "Projesiz grup kaldığı için işlem yapılamadı."
          return
        end
      
        User.where(role: "advisor").includes(projects: :groups).find_each do |advisor|
          code = advisor.advisor_code
          counter = 1
      
          advisor.projects.each do |project|
            project.groups.each do |group|
              group.update(name: "#{code}#{counter}")
              counter += 1
            end
          end
        end
      
        redirect_to admin_project_setting_path, notice: "Gruplar başarıyla yeniden adlandırıldı."
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
  