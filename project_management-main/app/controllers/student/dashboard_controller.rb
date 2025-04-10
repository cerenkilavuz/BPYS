module Student
  class DashboardController < ApplicationController
    before_action :only_students

    def index
      
    end
  end
end
