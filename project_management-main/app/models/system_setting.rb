class SystemSetting < ApplicationRecord
  validates :group_quota, numericality: {only_integer: true, greater_than: 0}, allow_nil: true    
  def self.instance
        first_or_create
      end

      def value_as_date
        Date.parse(value) rescue nil
      end
end
