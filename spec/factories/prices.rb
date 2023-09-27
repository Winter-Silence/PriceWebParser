# frozen_string_literal: true

FactoryBot.define do
  factory :price do
    association :product_parser_rule, factory: :product_parser_rule
    value { 150 }
  end
end
