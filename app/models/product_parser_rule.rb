# frozen_string_literal: true

class ProductParserRule < ApplicationRecord
  belongs_to :product
  has_many :prices, dependent: :destroy
end
