module Advisor
  class GroupsController < ApplicationController
    layout "advisor"
    before_action :authenticate_user!

    def index
      @groups = Group
        .includes(:leader, :students, :project) # eager loading
        .joins(:project)
        .where(projects: { advisor_id: current_user.id })
    end
  end
end
