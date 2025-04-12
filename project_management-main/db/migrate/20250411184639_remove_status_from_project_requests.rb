class RemoveStatusFromProjectRequests < ActiveRecord::Migration[7.1]
  def change
    remove_column :project_requests, :status, :integer
  end
end
