# frozen_string_literal: true

class Price < ApplicationRecord
  belongs_to :product_parser_rule
end
