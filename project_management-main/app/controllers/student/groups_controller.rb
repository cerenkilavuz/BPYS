class Student::GroupsController < ApplicationController
  layout "student"
  before_action :authenticate_user!
 

  def index
    @group = current_user.group
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.leader = current_user
    @group.name = "Grup #{SecureRandom.hex(3).upcase}"
  
    quota = SystemSetting.find_by(key: "group_quota")&.value.to_i
    quota = 0 if quota.nil?
    selected_student_ids = (params[:group][:student_ids] || []).reject(&:blank?)
  
    if selected_student_ids.uniq.length != selected_student_ids.length
      flash.now[:alert] = "Aynı öğrenci birden fazla kez eklenemez."
      return render :new
    end

    total_members = selected_student_ids.size + 1
  
    if quota > 0 && total_members > quota
      flash.now[:alert] = "Toplam grup üyesi sayısı kota olan #{quota} kişiyi aşamaz."
      return render :new
    end
  
    if @group.save
      GroupMembership.create(group: @group, student: current_user)
  
      selected_student_ids.each do |student_id|
        GroupMembership.create(group: @group, student_id: student_id)
      end
  
      redirect_to student_groups_path, notice: "Grup başarıyla oluşturuldu."
    else
      render :new
    end
  end
  
  
  def destroy
    @group = Group.find(params[:id])
    if @group.project_id.present?
      redirect_to student_groups_path, alert: "Bu grup bir projeye atanmış. Grup silinemez."
    else
      @group.destroy
      redirect_to student_groups_path, notice: "Grup başarıyla silindi."
    end
  end
  

  private

  def group_params
    params.require(:group).permit(:name, student_ids: [])
  end

  
end
