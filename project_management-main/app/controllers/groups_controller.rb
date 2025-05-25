class GroupsController < ApplicationController
    def create
      @group = Group.new(group_params)
  
      group_quota = SystemSetting.find_by(key: "group_quota")&.value.to_i
  
      selected_student_ids = params[:group][:student_ids].reject(&:blank?)
  
      total_members = selected_student_ids.size + 1  
  
      if group_quota > 0 && total_members > group_quota
        flash[:alert] = "Seçilen öğrenci sayısı, belirlenen grup kontenjanını (#{group_quota}) aşıyor!"
        return redirect_to new_group_path
      end
  
      if @group.save
        @group.students << Student.where(id: selected_student_ids)
        redirect_to groups_path, notice: "Grup başarıyla oluşturuldu."
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    private
  
    def group_params
      params.require(:group).permit(:name)
    end
  end