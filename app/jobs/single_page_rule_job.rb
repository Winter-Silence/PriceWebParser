# frozen_string_literal: true

class SinglePageRuleJob < ApplicationJob
  def perform(rule)
    parser = Parser::ProductPageParser.new(rule.url, timeout: rule.waits_timeout)
    price_value = parser.get_value(rule.selector)
    return if price_value.blank? || (!rule.lowest_price.nil? && rule.lowest_price <= price_value)

    price = Price.new(product_parser_rule: rule)
    price.value = price_value
    price.save
    TelegramBot.low_price_notification(rule, price)
  end

  private

  # todo: Нужно уведомлять о снижении цены, если она уменьшилась спустя месяц по отношению к цене, низжей в течение месяца
  def need_notification(product, price)

  end
end
