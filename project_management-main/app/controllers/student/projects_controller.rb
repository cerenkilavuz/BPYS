module Student
  class ProjectsController < ApplicationController
    before_action :authenticate_user! # Öğrencinin giriş yapmasını zorunlu kıl
    layout "student"

    def index
    end

    def published
      @projects = Project.includes(:advisor).where(published: true) # Yayınlanan projeleri çek ve danışman bilgisiyle getir
    end

    def proposals
      # proje teklifleri burada olacak
    end
  end
end
