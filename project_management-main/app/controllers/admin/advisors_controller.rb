module Admin
    class AdvisorsController < ApplicationController
      layout 'admin'
      before_action :authenticate_user!
      before_action :require_admin
      before_action :set_advisor, only: [:destroy]
  
      def new
        @advisor = User.new
        @advisors = User.where(role: "advisor")
      end
     
      def create
        random_password = Devise.friendly_token.first(10)
      
        @advisor = User.new(advisor_params)
        @advisor.role = 'advisor'
        @advisor.password = random_password
        @advisor.password_confirmation = random_password
        @advisor.must_change_password = true
      
        if @advisor.save
          AdvisorMailer.send_temporary_password(@advisor, random_password).deliver_later
          redirect_to new_admin_advisor_path, notice: 'Danışman başarıyla eklendi ve geçici şifresi gönderildi.'
        else
          @advisors = User.where(role: :advisor)
          render :new
        end
      end
     
      def destroy
        ActiveRecord::Base.transaction do
          @advisor = User.find(params[:id])
      
          @advisor.projects.find_each do |project|
            project.groups.find_each do |group| 
              ProjectRequest.where(group_id: group.id, project_id: project.id).destroy_all
              ProjectProposal.where(group_id: group.id, advisor_id: @advisor.id).destroy_all
      
              unless group.update(project_id: nil)
                raise ActiveRecord::Rollback, "Grubun proje bağlantısı kaldırılamadı."
              end

            end
      
            project.destroy!
          end
          
          @advisor.destroy!
        end
      
        redirect_to new_admin_advisor_path, notice: "Danışman başarıyla silindi."
      rescue => e
        redirect_to new_admin_advisor_path, alert: "Silme işlemi başarısız: #{e.message}"
      end
      
      private

      def set_advisor
        @advisor = User.find(params[:id])
      end

      def advisor_params
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
      end
  
      def require_admin
        redirect_to root_path unless current_user.admin?
      end
    end
  end
  