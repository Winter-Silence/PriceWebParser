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
    in Failure[String => error_message, *]
      handle_failure(rule, error_message)
    end
  end

  def handle_success(rule, price_value)
    return if price_value.blank?

    RulesError.where(product_parser_rule: rule).destroy_all

    date_begining_for_period_min_price = rule.product.period_lowest_price_in_days&.ago
    min_price_by_period = rule.product.lowest_price(since: date_begining_for_period_min_price)

    create_price(rule, price_value) if rule.prices.blank? || price_value < min_price_by_period

    return unless need_notification?(min_price_by_period, price_value)

    Notifier::TelegramBot.low_price_notification(rule, price_value)
  end

  def handle_failure(rule, error_message)
    ErrorHandlingService.new(rule, error_message).process
  end

  def create_price(rule, value)
    Price.create(product_parser_rule: rule, value:)
  end

  # Проверка, на сколько процентов уменьшилась цена
  def need_notification?(min_price_by_period, price_value)
    return false unless min_price_by_period

    price_decrease_percentage = (min_price_by_period - price_value.to_f) / min_price_by_period * 100
    price_decrease_percentage >= 5
  end
end
