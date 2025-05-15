class AddGroupQuotaToSystemSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :system_settings, :group_quota, :integer
  end
end
