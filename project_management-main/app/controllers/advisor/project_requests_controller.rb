module Advisor
    class ProjectRequestsController < ApplicationController
        before_action :set_project_request, only: [:accept, :reject]
    
        def accept
            @project = @project_request.project
          
            if @project.group.present?
              redirect_to advisor_projects_path, alert: 'Bu proje zaten bir gruba atanmış.'
              return
            end
          
            success = false
          
            ApplicationRecord.transaction do
              if @project_request.update(status: 'accepted')
                @project.update!(group: @project_request.group)
          
                # Diğer tüm başvuruları reddet
                @project.project_requests.where.not(id: @project_request.id).update_all(status: 'rejected')
          
                success = true
              else
                raise ActiveRecord::Rollback
              end
            end
          
            if success
              redirect_to advisor_projects_path, notice: 'Proje başarıyla kabul edildi ve gruba atandı.'
            else
              redirect_to advisor_projects_path, alert: 'Projeyi kabul ederken bir hata oluştu.'
            end
          rescue => e
            redirect_to advisor_projects_path, alert: "Hata oluştu: #{e.message}"
          end
          
    
        def reject
        if @project_request.update(status: 'rejected')
            redirect_to advisor_projects_requests_path, notice: 'Başvuru reddedildi.'
        else
            redirect_to advisor_projects_requests_path, alert: 'Reddetme sırasında bir hata oluştu.'
        end
        end
    
        private
    
        def set_project_request
        @project_request = ProjectRequest.find(params[:id])
        end
    end
end    