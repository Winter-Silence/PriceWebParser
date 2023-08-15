# frozen_string_literal: true

class ProductParserRule < ApplicationRecord
  belongs_to :product
  has_many :prices, dependent: :destroy

  scope :outdated_rules, -> { where('last_run < ?', 30.minutes.ago) }

  def lowest_price
    prices.minimum(:value).to_i
  end
end
