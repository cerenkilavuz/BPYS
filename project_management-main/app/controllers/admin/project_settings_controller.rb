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

        unless deadline
          return redirect_to edit_admin_project_setting_path, alert: "Proje seçim tarihi belirlenmemiş."
        end
        
        if Date.today <= deadline
          return redirect_to edit_admin_project_setting_path, alert: "Proje seçim süreci henüz tamamlanmadı. Rastgele atama yapılamaz."
        end
        
        unassigned_groups = Group.where(project_id: nil)
        
        if unassigned_groups.empty?
          return redirect_to edit_admin_project_setting_path, alert: "Proje seçimi yapmamış grup bulunmamaktadır."
        end

        students_without_group = User.where(role: 'student')
                             .left_joins(:group_membership)
                             .where(group_membership: { id: nil })

        if students_without_group.exists?
          student_emails = students_without_group.pluck(:email).join(", ")
          flash[:alert] = "Grubu olmayan öğrenciler mevcut: #{student_emails}. Önce tüm öğrencileri gruplandırın."
          redirect_back(fallback_location: root_path)
          return
        end

      
        advisors = User.where(role: :advisor)

        unassigned_groups.each do |group|
          advisor_group_counts = advisors.index_with do |advisor|
            Project.where(advisor_id: advisor.id).joins(:groups).count
          end
        
          min_group_count = advisor_group_counts.values.min
        
          # Danışmanları grup sayısına göre artan sırada listele
          sorted_advisors = advisor_group_counts.sort_by { |_, count| count }.map(&:first)
        
          assigned = false
        
          sorted_advisors.each do |advisor|
            advisor_projects = Project.where(advisor_id: advisor.id)
        
            available_projects = advisor_projects.select do |project|
              (project.quota - project.groups.count) > 0
            end
        
            next if available_projects.empty?
        
            project_group_counts = available_projects.index_with { |project| project.groups.count }
            min_project_group_count = project_group_counts.values.min
            least_used_projects = project_group_counts.select { |_, count| count == min_project_group_count }.keys
        
            selected_project = least_used_projects.sample
        
            group.update(project: selected_project)
            assigned = true
            break
          end
        
          unless assigned
            Rails.logger.warn "Gruba atanacak uygun proje bulunamadı: Grup ID #{group.id}"
          end
        end
        
        redirect_to admin_project_setting_path, notice: "Projeler rastgele atandı."
      end
      
      
      
      def rename_groups
        if Group.where(project_id: nil).exists?
          redirect_to admin_project_setting_path, alert: "Projesiz grup kaldığı için işlem yapılamadı."
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
          
      def export_groups_to_csv
        groups = Group.includes(:students, project: :advisor)
                      .where.not(project_id: nil) # Sadece projeye atanmış gruplar
      
        groups_by_advisor = groups.group_by { |g| g.project.advisor }
      
        csv_data = CSV.generate(headers: false) do |csv|
          csv << ["Bitirme Projesi Gruplar-Danışmanlar"]
      
          groups_by_advisor.each do |advisor, advisor_groups|
            csv << ["Danışman: #{advisor&.full_name || 'Bilinmiyor'}"]
            csv << ["Grup Adı", "Grup Üyeleri", "Proje Başlığı"]
      
            sorted_groups = advisor_groups.sort_by { |g| g.name }

            sorted_groups.each do |group|
              student_list = group.students.each_with_index.map do |s, i|
                "#{i + 1}) #{s.full_name} - #{s.student_number}"
              end.join("\n")
      
              csv << [group.name, student_list, group.project.title]
            end
      
            csv << [] # Her danışmandan sonra boşluk satırı
          end
        end
      
        bom = "\uFEFF"
        send_data bom + csv_data,
                  filename: "proje_secimi_yapan_gruplar_#{Date.today}.csv",
                  type: "text/csv; charset=utf-8"
      end
      
      private
  
      def system_setting_params
        params.require(:system_setting).permit(:value)
      end
  
      def groups_with_projects(deadline)
        Group.where.not(project_id: nil)
      end
      
      def groups_without_project(deadline)
        Group.where(project_id: nil)
      end
          
  
      def require_admin
        redirect_to root_path unless current_user.admin?
      end
    end
  end
  