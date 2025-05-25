class AddProjectIdToProjectProposals < ActiveRecord::Migration[7.1]
  def change
    add_column :project_proposals, :project_id, :integer
    add_foreign_key :project_proposals, :projects
  end
end
