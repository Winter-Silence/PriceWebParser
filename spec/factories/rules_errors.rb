# frozen_string_literal: true

FactoryBot.define do
  factory :rules_error do
    error_type { :unrecognized }
    message { 'error message' }
    association :product_parser_rule, factory: :product_parser_rule
  end
end
