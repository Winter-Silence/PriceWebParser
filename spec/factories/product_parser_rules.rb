# frozen_string_literal: true

FactoryBot.define do
  factory :product_parser_rule do
    url { 'www.page.ru/product' }
    selector { 'a.class="price"' }
    active { true }
    last_run { 1.day.ago }
    association :product, factory: :product
  end
end
