# frozen_string_literal: true

module PriceQueryable
  extend ActiveSupport::Concern

  included do
    def lowest_price(since: nil)
      return unless since.nil? || valid_date?(since)

      prices.where(created_at: since..).minimum(:value)
    end

    def valid_date?(value)
      if value.is_a?(ActiveSupport::TimeWithZone) || value.is_a?(DateTime) ||
         begin
           value.is_a?(String) && DateTime.parse(value)
         rescue ArgumentError
           false
         end
        true
      else
        raise ArgumentError,
              "Параметр 'since' должен быть типа DateTime или строкой с корректным форматом даты и времени."
      end
    end
  end
end
