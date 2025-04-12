module Advisor
  class ProjectRequestsController < ApplicationController
    before_action :set_project_request, only: [:accept, :reject]

    def accept
      @project = @project_request.project
      @group = @project_request.group

      Rails.logger.debug "Grup ID: #{@group.id} | Mevcut proje ID: #{@group.project_id}"
      Rails.logger.debug "Proje ID: #{@project.id} | Kontenjan: #{@project.quota} | Şu anki grup sayısı: #{@project.groups.count}"

      if @group.project.present?
        redirect_back fallback_location: advisor_project_requests_path, alert: 'Bu grup zaten bir projeye atanmış.'
        return
      end

      if @project.quota.present? && @project.groups.count >= @project.quota
        redirect_back fallback_location: advisor_project_requests_path, alert: 'Projenin kontenjanı dolmuş.'
        return
      end

      success = false

      ApplicationRecord.transaction do
        unless @project_request.update(status: 'accepted')
          Rails.logger.debug "ProjectRequest güncellenemedi: #{@project_request.errors.full_messages}"
          raise ActiveRecord::Rollback
        end

        @group.update!(project: @project)

        @project.project_requests
                .where.not(id: @project_request.id)
                .where(group: @group)
                .update_all(status: 'rejected')

        success = true
      end

      if success
        redirect_back fallback_location: advisor_project_requests_path, notice: 'Proje başarıyla kabul edildi ve gruba atandı.'
      else
        redirect_back fallback_location: advisor_project_requests_path, alert: 'Projeyi kabul ederken bir hata oluştu.'
      end
    rescue => e
      Rails.logger.debug "Accept işleminde hata: #{e.message}"
      redirect_back fallback_location: advisor_project_requests_path, alert: "Hata oluştu: #{e.message}"
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
