class AddKeyAndValueToSystemSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :system_settings, :key, :string
    add_column :system_settings, :value, :string
  end
end
