# frozen_string_literal: true

require 'notifier/telegram_bot'

class SinglePageRuleJob < ApplicationJob
  include Dry::Monads[:result]

  def perform(rule)
    parse_and_process(rule)
  end

  private

  def parse_and_process(rule)
    parser = Parser::ProductPageParser.new(rule.url, timeout: rule.waits_timeout)

    case parser.get_value(rule.selector)
    in Success(parsed_price)
      handle_success(rule, parsed_price)
    in Failure(error_message)
      handle_failure(rule, error_message)
    end
  end

  def handle_success(rule, price_value)
    RulesError.where(product_parser_rule: rule).destroy_all if price_value.present?

    return if price_value.blank? || (!rule.lowest_price.nil? && rule.lowest_price <= price_value)

    product_lowest_price = rule.product.lowest_price
    create_price(rule, price_value)

    return unless need_notification(product_lowest_price, price_value)

    Notifier::TelegramBot.low_price_notification(rule, price_value)
  end

  def handle_failure(rule, error_message)
    Rails.logger.error("#{rule.url}: #{error_message}")
    ErrorHandlingService.new(rule, error_message).process
  end

  def create_price(rule, value)
    Price.create(product_parser_rule: rule, value:)
  end

  def need_notification(lowest_price, price_value)
    return false unless lowest_price

    price_decrease_percentage = (lowest_price - price_value.to_f) / lowest_price * 100
    price_decrease_percentage >= 5
  end
end
