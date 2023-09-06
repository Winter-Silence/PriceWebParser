# frozen_string_literal: true

class RulesError < ApplicationRecord
  belongs_to :product_parser_rule

  enum :error_type, { element_not_found: 1, unrecognized: 2 }
end
