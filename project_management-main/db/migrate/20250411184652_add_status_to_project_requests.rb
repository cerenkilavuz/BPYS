class AddStatusToProjectRequests < ActiveRecord::Migration[7.1] # veya senin Rails versiyonun
  def change
    add_column :project_requests, :status, :integer, default: 0
  end
end
