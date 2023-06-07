# frozen_string_literal: true

namespace :single_page_parser do
  desc 'Collects prices from the specified pages of each product'
  task parse: :environment do
    Product.eager_load(product_parser_rules: :prices).each do |product|
      product.product_parser_rules.each do |rule|
        ParserSinglePage.perform_now(product, rule)
      end
    end
  end
end
