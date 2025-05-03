module Admin
  class DashboardController < ApplicationController
    layout 'admin'
    before_action :only_admins

    def index
      @users = User.all
    end
  end
end
