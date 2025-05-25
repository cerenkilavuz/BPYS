module Advisor
  class ProjectRequestsController < ApplicationController
    before_action :set_project_request, only: [:accept, :reject]

    def accept
      @project = @project_request.project
      @group = @project_request.group

      if @group.project.present?
        redirect_back fallback_location: advisor_project_requests_path, alert: 'Bu grup zaten bir projeye atanmış.'
        return
      end

      if @project.quota.present? && @project.groups.count >= @project.quota
        redirect_back fallback_location: advisor_project_requests_path, alert: 'Projenin kontenjanı dolmuş.'
        return
      end

      ApplicationRecord.transaction do
        @project_request.update!(status: 'accepted')
        @group.update!(project: @project)

        @project.project_requests
                .where.not(id: @project_request.id)
                .where(group: @group)
                .update_all(status: 'rejected')
      end

      redirect_back fallback_location: advisor_project_requests_path, notice: 'Proje başarıyla kabul edildi ve gruba atandı.'
    rescue => e
      redirect_back fallback_location: advisor_project_requests_path, alert: 'Projeyi kabul ederken bir hata oluştu.'
    end

    def reject
      if @project_request.update(status: 'rejected')
        redirect_back fallback_location: advisor_project_requests_path, notice: 'Başvuru reddedildi.'
      else
        redirect_back fallback_location: advisor_project_requests_path, alert: 'Reddetme sırasında bir hata oluştu.'
      end
    end

    private

    def set_project_request
      @project_request = ProjectRequest.find(params[:id])
    end
  end
end
