# frozen_string_literal: true

class ProductParserRule < ApplicationRecord
  before_save :convert_cookies_to_json

  belongs_to :product
  has_many :prices, dependent: :destroy
  has_many :rules_errors, dependent: :destroy

  scope :outdated_rules, -> { where('last_run < ?', 30.minutes.ago) }
  scope :only_active, -> { where(active: true) }

  def lowest_price
    prices.minimum(:value)
  end

  private

  def convert_cookies_to_json
    self.cookies = JSON.parse(cookies)
  end
end
