# frozen_string_literal: true

class SinglePageRuleJob < ApplicationJob
  def perform(rule)
    parser = Parser::ProductPageParser.new(rule.url)
    price_value = parser.get_value(rule.selector)
    return if price_value.blank? || (!rule.lowest_price.nil? && rule.lowest_price <= price_value.to_id)

    price = Price.new(product_parser_rule: rule)
    price.value = price_value
    price.save
    TelegramBot.low_price_notification(rule, price)
  end
end
