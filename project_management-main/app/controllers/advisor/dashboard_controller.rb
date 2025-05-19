module Advisor
  class DashboardController < Advisor::BaseController
    layout "advisor"
    before_action :only_advisors

    def index
      
    end
  end
end


