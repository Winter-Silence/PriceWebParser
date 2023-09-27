# frozen_string_literal: true

class ProductParserRule < ApplicationRecord
  include PriceQueryable

  before_save :convert_cookies_to_json

  belongs_to :product
  has_many :prices, dependent: :destroy
  has_many :rules_errors, dependent: :destroy

  scope :outdated_rules, -> { where('last_run < ?', 30.minutes.ago) }
  scope :only_active, -> { where(active: true) }

  private

  def convert_cookies_to_json
    self.cookies = JSON.parse(cookies.to_s)
  end
end
