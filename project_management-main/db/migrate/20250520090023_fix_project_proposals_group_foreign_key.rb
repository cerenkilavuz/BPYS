class FixProjectProposalsGroupForeignKey < ActiveRecord::Migration[7.1]
  def change
    # Bu şekilde tanımlarsan hatasız çalışması gerekir
    remove_foreign_key :project_proposals, to_table: :users, column: :group_id

    # Ardından doğru olanı ekle
    add_foreign_key :project_proposals, :groups, column: :group_id
  end
end
