# frozen_string_literal: true

require 'notifier/telegram_bot'

class SinglePageRuleJob < ApplicationJob
  include Dry::Monads[:result]

  def perform(rule)
    parse_and_process(rule)
  end

  private

  def parse_and_process(rule)
    parser = Parser::ProductPageParser.new(rule.url, timeout: rule.waits_timeout, cookies: rule.cookies)

    case parser.get_value(rule.selector)
    in Success(parsed_price)
      handle_success(rule, parsed_price)
    in Failure[String =>  error_message, *]
      handle_failure(rule, error_message)
    end
  end

  def handle_success(rule, price_value)
    return if price_value.blank?

    RulesError.where(product_parser_rule: rule).destroy_all
    rule_lowest_price = rule.lowest_price

    create_price(rule, price_value) if rule_lowest_price.nil? || rule_lowest_price > price_value

    period_lowest_price = Product.period_lowest_prices[rule.product.period_lowest_price]&.to_i&.days&.ago
    lowest_price_by_period = rule.product.lowest_price(since: period_lowest_price)

    return unless need_notification(lowest_price_by_period, price_value)

    Notifier::TelegramBot.low_price_notification(rule, price_value)
  end

  def handle_failure(rule, error_message)
    Rails.logger.error("#{rule.url}: #{error_message}")
    ErrorHandlingService.new(rule, error_message).process
  end

  def create_price(rule, value)
    Price.create(product_parser_rule: rule, value:)
  end

  # Проверка, на сколько процентов уменьшилась цена
  def need_notification(lowest_price, price_value)
    return false unless lowest_price

    price_decrease_percentage = (lowest_price - price_value.to_f) / lowest_price * 100
    price_decrease_percentage >= 5
  end
end
