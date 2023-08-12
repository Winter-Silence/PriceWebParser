# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :product_parser_rules, dependent: :destroy
  has_many :prices, through: :product_parser_rules

  def lowest_price
    prices.minimum(:value).to_i
  end
end
