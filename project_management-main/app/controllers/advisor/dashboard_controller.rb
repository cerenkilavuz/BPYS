module Advisor
  class DashboardController < ApplicationController
    layout "advisor"
    before_action :only_advisors

    def index
      
    end
  end
end


