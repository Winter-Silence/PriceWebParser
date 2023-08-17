# frozen_string_literal: true

class ProductParserRule < ApplicationRecord
  belongs_to :product
  has_many :prices, dependent: :destroy

  scope :outdated_rules, -> { where('last_run < ?', 30.minutes.ago) }
  scope :only_active, -> { where(active: true) }

  def lowest_price
    prices.minimum(:value)
  end
end
