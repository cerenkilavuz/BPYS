module Student
  class ProjectsController < ApplicationController
    before_action :authenticate_user! # Öğrencinin giriş yapmasını zorunlu kıl

    def index
      @projects = Project.includes(:advisor).where(published: true) # Yayınlanan projeleri çek ve danışman bilgisiyle getir
    end
  end
end
