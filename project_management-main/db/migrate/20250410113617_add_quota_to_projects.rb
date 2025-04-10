class AddQuotaToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :quota, :integer, default: 0
  end
end
