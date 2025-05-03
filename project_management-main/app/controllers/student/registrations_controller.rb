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
  end
  