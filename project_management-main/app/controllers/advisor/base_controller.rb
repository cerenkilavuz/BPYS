class Advisor::BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_password_change
    before_action :ensure_advisor
  
    private
  
    def require_password_change
      if current_user.must_change_password? && request.fullpath != edit_advisor_password_path
        redirect_to edit_advisor_password_path, alert: "Lütfen şifrenizi değiştirin."
      end
    end
  
    def ensure_advisor
      redirect_to root_path unless current_user&.advisor?
    end
  end
  