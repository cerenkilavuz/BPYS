require 'csv'
module Admin
    class SettingsController < ApplicationController
    layout 'admin'
    before_action :authenticate_user!
    before_action :require_admin


      
    def edit
        @deadline = SystemSetting.find_or_initialize_by(key: 'group_creation_deadline')
        @project_deadline = SystemSetting.find_or_initialize_by(key: 'project_selection_deadline')
        @students_without_group = unassigned_students
        @groups = Group.includes(:students).all  # tüm grupları yükle
        @group_quota = SystemSetting.find_or_initialize_by(key: 'group_quota')
    end
  

    def update
        @deadline = SystemSetting.find_or_initialize_by(key: 'group_creation_deadline')
        if @deadline.update(value: params[:system_setting][:value])  # params[:system_setting] => formdan gelen model parametresi
          redirect_to edit_admin_setting_path, notice: "Son tarih güncellendi."
        else
          render :edit
        end
    end
      
    def show
        @deadline = SystemSetting.find_or_initialize_by(key: "deadline")
        @group_quota = SystemSetting.find_or_initialize_by(key: "group_quota")
    end
        
    def update_group_quota
        @group_quota = SystemSetting.find_or_initialize_by(key: "group_quota")
        @group_quota.update(value: params[:system_setting][:value])
        
        redirect_to edit_admin_setting_path, notice: "Grup kontenjanı güncellendi."
    end  
      

    def export_unassigned_students
        @deadline = SystemSetting.find_by(key: 'group_creation_deadline')
        @students_without_group = unassigned_students
      
        respond_to do |format|
          format.csv do
            csv_data = CSV.generate(headers: true) do |csv|
              csv << ["Email", "Kayıt Tarihi"]
              @students_without_group.each do |student|
                csv << [student.email, student.created_at.strftime("%d.%m.%Y")]
              end
            end
      
            send_data csv_data,
                      filename: "grup_olusturmamis_ogrenciler_#{Date.today}.csv",
                      type: 'text/csv; charset=utf-8'
          end
        end
    end

    def email_unassigned_students
        @students_without_group = unassigned_students
        @students_without_group.each do |student|
          StudentMailer.group_reminder_email(student).deliver_later
        end
        redirect_to edit_admin_setting_path, notice: "Hatırlatma e-postaları gönderildi."
    end
    
    def random_group_students
        ungrouped_students = unassigned_students.shuffle
        groups = []
      
        while ungrouped_students.size >= 3
          if ungrouped_students.size == 4
            groups << ungrouped_students.pop(2)
            groups << ungrouped_students.pop(2)
          else
            groups << ungrouped_students.pop(3)
          end
        end
      
        groups << ungrouped_students.pop(2) if ungrouped_students.size == 2
      
        groups.each do |members|
          leader = members.first
          group = Group.create!(name: "Grup #{SecureRandom.hex(3)}", leader: leader)
          members.each do |student|
            GroupMembership.create!(group: group, student: student)
          end
        end
      
        redirect_to edit_admin_setting_path, notice: "Grup oluşturmamış öğrenciler başarıyla rastgele gruplandırıldı."
      rescue => e
        redirect_to edit_admin_setting_path, alert: "Bir hata oluştu: #{e.message}"
    end
      

    private
    def unassigned_students
        deadline = SystemSetting.find_by(key: 'group_creation_deadline')&.value
        return [] unless deadline.present?
    
        User.students
            .left_outer_joins(:group_membership)
            .where(group_memberships: { id: nil })
            .where("users.created_at <= ?", deadline.to_date.end_of_day)
    end

  
    def require_admin
      redirect_to root_path unless current_user.admin?
    end

    def system_setting_params
        params.require(:system_setting).permit(:value)
    end

end
end
