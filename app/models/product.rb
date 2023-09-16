# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :product_parser_rules, dependent: :destroy
  has_many :prices, through: :product_parser_rules

  enum :period_lowest_price, { 'два месяца': 60,
                               месяц: 30,
                               'три месяца': 90,
                               'две недели': 14,
                               'три недели': 21 }

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
