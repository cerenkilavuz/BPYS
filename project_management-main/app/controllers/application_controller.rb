
class ApplicationController < ActionController::Base
    before_action :authenticate_user! 
    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :check_student_login
    before_action :set_current_user
    
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

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
      end
    
      def check_student_login
        return unless current_user&.student?
      
        if !SystemSetting.instance.students_can_login
          sign_out current_user
          redirect_to root_path, alert: "Sistem şu anda öğrenci girişine kapalıdır."
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

    def set_current_user
      Current.user = current_user
    end
end

