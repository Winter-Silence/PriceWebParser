# frozen_string_literal: true

class Product < ApplicationRecord
  has_many :product_parser_rules, dependent: :destroy
end
