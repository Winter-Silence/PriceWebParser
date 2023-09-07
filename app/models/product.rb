# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :product_parser_rules, dependent: :destroy
  has_many :prices, through: :product_parser_rules

  def lowest_price(since: nil)
    return unless since.nil? || valid_date?(since)

    prices.where(created_at: since..).minimum(:value)
  end

  private

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
