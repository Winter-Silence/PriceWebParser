# frozen_string_literal: true

class Product < ApplicationRecord
  include PriceQueryable

  has_many :product_parser_rules, dependent: :destroy
  has_many :prices, through: :product_parser_rules

  alias_attribute :rules, :product_parser_rules

  enum :period_lowest_price, { 'два месяца': 60,
                               месяц: 30,
                               'три месяца': 90,
                               'две недели': 14,
                               'три недели': 21 }

  def period_lowest_price_in_days
    self.class.period_lowest_prices[period_lowest_price]&.to_i&.days
  end
end
