# app/controllers/advisor/passwords_controller.rb
class Advisor::PasswordsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_advisor
  
    def edit
    end
  
    def update
      if current_user.update_with_password(password_params)
        current_user.update(must_change_password: false)
        bypass_sign_in(current_user)
        redirect_to advisor_dashboard_path, notice: "Şifreniz başarıyla güncellendi."
      else
        render :edit
      end
    end
  
    private
  
    def ensure_advisor
      redirect_to root_path unless current_user&.advisor?
    end
  
    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
  end
  