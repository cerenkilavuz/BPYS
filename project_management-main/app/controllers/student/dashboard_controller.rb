module Student
  class DashboardController < ApplicationController 
    layout "student"
    before_action :only_students
    
    def index
      
    end
  end
end
