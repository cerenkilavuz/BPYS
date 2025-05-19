class Student::RegistrationsController < Devise::RegistrationsController
    def new
      unless SystemSetting.instance.students_can_register
        redirect_to root_path, alert: "Yeni kayıtlar şu anda kapalı."
        return
      end
  
      super
    end
  
    def create
      unless SystemSetting.instance.students_can_register
        redirect_to root_path, alert: "Yeni kayıtlar şu anda kapalı."
        return
      end
  
      super
    end

    def sign_up(resource_name, resource)
      # Hiçbir işlem yapma => otomatik oturum açılmaz
    end
  
    def after_sign_up_path_for(resource)
      flash[:notice] = "Kayıt başarılı! Lütfen giriş yapınız."
      new_user_session_path 
    end
  
    def after_inactive_sign_up_path_for(resource)
      flash[:notice] = "Kayıt başarılı! Lütfen giriş yapınız."
      new_user_session_path # eğer :confirmable varsa, yine giriş sayfasına yönlendir
    end
  end
  