class SystemSetting < ApplicationRecord
      def self.instance
        first_or_create
      end

      def value_as_date
        Date.parse(value) rescue nil
      end
end
