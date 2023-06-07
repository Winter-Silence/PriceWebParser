# frozen_string_literal: true

# require 'lib/parser/product_page_parser'

class ParserSinglePage < ApplicationJob
  def perform(product, parser_rule)
    parser = Parser::ProductPageParser.new(parser_rule.url)
    price_value = parser.get_value(parser_rule.selector)
    return if price_value.nil? || (!product.lowest_price.nil? && product.lowest_price <= price_value)

    price = Price.new(product_parser_rule: parser_rule)
    price.value = price_value
    price.save
  end
end
