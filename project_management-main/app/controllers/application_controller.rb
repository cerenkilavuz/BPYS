
class ApplicationController < ActionController::Base
    before_action :authenticate_user! # Kullanıcı giriş yapmadan hiçbir sayfaya erişemez
    
      def after_sign_in_path_for(resource)
        case resource.role
        when "admin"
          admin_dashboard_path
        when "advisor"
          advisor_dashboard_path
        when "student"
          student_dashboard_path
        else
          root_path
        end
      end
    
    
  
    private
  
    def only_admins
      redirect_to root_path, alert: "Bu sayfaya erişiminiz yok!" unless current_user&.admin?
    end
  
    def only_advisors
      redirect_to root_path, alert: "Bu sayfaya erişiminiz yok!" unless current_user&.advisor?
    end
  
    def only_students
      redirect_to root_path, alert: "Bu sayfaya erişiminiz yok!" unless current_user&.student?
    end
end

