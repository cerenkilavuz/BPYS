module Admin
    class AdvisorsController < ApplicationController
      layout 'admin'
        before_action :authenticate_user!
      before_action :require_admin
  
      def new
        @advisor = User.new
      end
  
      def create
        @advisor = User.new(advisor_params)
        @advisor.role = 'advisor'  # Danışman rolü atanıyor
  
        if @advisor.save
          redirect_to admin_dashboard_path, notice: 'Danışman başarıyla eklendi.'
        else
          render :new
        end
      end
  
      private
  
      def advisor_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
  
      def require_admin
        redirect_to root_path unless current_user.admin?
      end
    end
  end
  