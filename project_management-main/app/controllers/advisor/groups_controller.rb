module Advisor
    class GroupsController < ApplicationController
      before_action :authenticate_user!
      
      def index
        @accepted_projects = current_user.projects.includes(:group).where.not(group: nil)
      end
    end
  end
  