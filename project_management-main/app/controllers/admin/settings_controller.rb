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
        @groups = Group.includes(:students).all 
        @group_quota = SystemSetting.find_or_initialize_by(key: 'group_quota')
    end
  

    def update
        @deadline = SystemSetting.find_or_initialize_by(key: 'group_creation_deadline')
        if @deadline.update(value: params[:system_setting][:value])  
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
      

    def email_unassigned_students
        @students_without_group = unassigned_students
        @students_without_group.each do |student|
          StudentMailer.group_reminder_email(student).deliver_later
        end
        redirect_to edit_admin_setting_path, notice: "Hatırlatma e-postaları gönderildi."
    end
    
    def random_group_students
      deadline = SystemSetting.find_by(key: 'group_creation_deadline')&.value_as_date
    
      unless deadline
        return redirect_to edit_admin_setting_path, alert: "Son grup oluşturma tarihi belirlenmemiş."
      end
    
      if Date.today <= deadline
        return redirect_to edit_admin_setting_path, alert: "Grup oluşturma süreci henüz tamamlanmadı. Rastgele gruplandırma yapılamaz."
      end
    
      group_quota = SystemSetting.find_by(key: 'group_quota')&.value.to_i
      unless group_quota > 0
        return redirect_to edit_admin_setting_path, alert: "Geçerli bir grup kontenjanı (group_quota) belirlenmemiş."
      end
    
      ungrouped_students = unassigned_students.shuffle
      total = ungrouped_students.size
      groups = []
    
      while ungrouped_students.size >= group_quota
        if ungrouped_students.size == group_quota + 1
          if (group_quota + 1).odd?
            half = (group_quota + 2) / 2
            groups << ungrouped_students.pop(half)
            groups << ungrouped_students.pop(half)
          else
            half = (group_quota + 1) / 2
            groups << ungrouped_students.pop(half)
            groups << ungrouped_students.pop(half)
          end
        else
          groups << ungrouped_students.pop(group_quota)
        end
      end
    
      if ungrouped_students.size < group_quota && ungrouped_students.size > 0
        groups << ungrouped_students.pop(ungrouped_students.size)
      end

      
      groups.each do |members|
        leader = members.first
        group = Group.create!(name: "Grup #{SecureRandom.hex(3).upcase}", leader: leader)
        members.each do |student|
          GroupMembership.create!(group: group, student: student)
        end
      end
    
      redirect_to edit_admin_setting_path, notice: "Grup oluşturmamış öğrenciler başarıyla gruplandırıldı."
    rescue => e
      redirect_to edit_admin_setting_path, alert: "Bir hata oluştu."
    end
    
      

    private
    def unassigned_students
      User.students
          .left_outer_joins(:group_membership)
          .where(group_memberships: { id: nil })
    end
    

  
    def require_admin
      redirect_to root_path unless current_user.admin?
    end

    def system_setting_params
        params.require(:system_setting).permit(:value)
    end

end
end
