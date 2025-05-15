class GroupsController < ApplicationController
    def create
      @group = Group.new(group_params)
  
      # Kontenjan ayarını al
      group_quota = SystemSetting.find_by(key: "group_quota")&.value.to_i
  
      # Öğrenci ID'lerini al ve boş olanları temizle
      selected_student_ids = params[:group][:student_ids].reject(&:blank?)
  
      # Grubun toplam üye sayısını hesapla (lider hariç)
      total_members = selected_student_ids.size + 1  # 1, liderin sayılması için
  
      # Kotayı kontrol et
      if group_quota > 0 && total_members > group_quota
        flash[:alert] = "Seçilen öğrenci sayısı, belirlenen grup kontenjanını (#{group_quota}) aşıyor!"
        return redirect_to new_group_path
      end
  
      # Grubu kaydet
      if @group.save
        # Öğrencileri gruba ekle (lider hariç)
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