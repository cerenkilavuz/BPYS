class Users::RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_user!, only: [:edit, :update, :destroy]
    layout :determine_layout
  
    def new
      if sign_up_student?
        unless SystemSetting.instance.students_can_register
          redirect_to root_path, alert: "Yeni kayıtlar şu anda kapalı."
          return
        end
      end
  
      super
    end
  
    def create
      if sign_up_student?
        unless SystemSetting.instance.students_can_register
          redirect_to root_path, alert: "Yeni kayıtlar şu anda kapalı."
          return
        end
      end
  
      super
    end
  
    def after_sign_up_path_for(resource)
      if resource.student?
        flash[:notice] = "Kayıt başarılı! Lütfen giriş yapınız."
        new_user_session_path
      else
        super
      end
    end
  
    def after_inactive_sign_up_path_for(resource)
      if resource.student?
        flash[:notice] = "Kayıt başarılı! Lütfen giriş yapınız."
        new_user_session_path
      else
        super
      end
    end
  
    def update
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
  
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
  
      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?
  
      if resource_updated
        bypass_sign_in resource, scope: resource_name
        redirect_to edit_user_registration_path, notice: "Şifreniz başarıyla güncellendi."
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  
    def destroy
      return if Current.user&.admin?
      user = resource
  
      if user.student? && user.group.present?
        redirect_to edit_user_registration_path, alert: "Bir gruba üye olduğunuz için hesabınızı silemezsiniz."
      elsif user.advisor? && user.projects.exists?
        redirect_to edit_user_registration_path, alert: "Üzerinize tanımlı projeler olduğu için hesabınızı silemezsiniz."
      else
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        user.destroy
        set_flash_message! :notice, :destroyed
        yield user if block_given?
        redirect_to after_sign_out_path_for(resource_name)
      end
    end
  
    def sign_up(resource_name, resource)
    end
  
    private
  
    def determine_layout
      return "admin" if Current.user&.admin?
      return "student" if Current.user&.student?
      return "advisor" if Current.user&.advisor?
      "application"
    end
  
    def sign_up_student?
      role = params.dig(:user, :role)
      role == "student"
    end
  end
  