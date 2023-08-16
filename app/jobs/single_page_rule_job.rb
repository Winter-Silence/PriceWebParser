# frozen_string_literal: true

class SinglePageRuleJob < ApplicationJob
  include Dry::Monads[:result]

  def perform(rule)
    parser = Parser::ProductPageParser.new(rule.url, timeout: rule.waits_timeout)
    case parser.get_value(rule.selector)
    in Success(price_value)
      return if price_value.blank? || (!rule.lowest_price.nil? && rule.lowest_price <= price_value)

      price = Price.new(product_parser_rule: rule)
      price.value = price_value
      price.save
      TelegramBot.low_price_notification(rule, price)
    in Failure(error_message)
      Rails.logger.error(error_message)
    end
  end

  private

  # TODO: Нужно уведомлять о снижении цены, если она уменьшилась спустя месяц по отношению к цене, низжей в течение месяца
  def need_notification(product, price); end
end
