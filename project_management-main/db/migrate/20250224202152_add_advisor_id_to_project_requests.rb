class AddAdvisorIdToProjectRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :project_requests, :advisor_id, :integer
  end
end
