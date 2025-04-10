
class AddAdvisorIdToProjects < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :advisor_id, :integer
    add_index :projects, :advisor_id  # Danışman sorgularını hızlandırmak için index ekleyelim
  end
end
