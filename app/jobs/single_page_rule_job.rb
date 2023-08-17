# frozen_string_literal: true

class SinglePageRuleJob < ApplicationJob
  include Dry::Monads[:result]

  def perform(rule)
    parser = Parser::ProductPageParser.new(rule.url, timeout: rule.waits_timeout)
    case parser.get_value(rule.selector)
    in Success(price_value)
      return if price_value.blank? || (!rule.lowest_price.nil? && rule.lowest_price <= price_value)

      product_lowest_price = product.lowest_price
      price = Price.new(product_parser_rule: rule)
      price.value = price_value
      price.save
      TelegramBot.low_price_notification(rule, price) if need_notification(product_lowest_price, price_value)
    in Failure(error_message)
      Rails.logger.error("#{rule.url}: #{error_message}#")
    end
  end

  private

  # Уведомляем, если цена снизилась на 5% и больше
  def need_notification(lowest_price, price_value)
    lowest_price > price_value && (lowest_price / price_value * 100) >= 5
  end
end
