# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#   
User.create(email: "admin@example.com", password: "123123", role: :admin)

SystemSetting.find_or_create_by(key: 'group_creation_deadline') do |system_setting|
    system_setting.value = (Date.today + 7.days).to_s # varsayılan olarak 7 gün sonrası
  end
 
SystemSetting.find_or_create_by(key: 'project_selection_deadline') do |system_setting|
    system_setting.value = (Date.today + 7.days).to_s # varsayılan olarak 7 gün sonrası
  end
