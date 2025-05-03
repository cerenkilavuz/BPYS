module Student
  class ProjectsController < ApplicationController
    before_action :authenticate_user! # Öğrencinin giriş yapmasını zorunlu kıl
    layout "student"

    def index
      @group = current_user.group
    end

    def published
      @projects = Project.includes(:advisor).where(published: true) # Yayınlanan projeleri çek ve danışman bilgisiyle getir
    end

    def proposals
      @project_proposals = ProjectProposal.where(group_id: current_user.group.id)
    end
    
    
  end
end
