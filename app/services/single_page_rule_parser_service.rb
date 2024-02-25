# frozen_string_literal: true

class SinglePageRuleParserService
  include Dry::Monads[:result]

  def initialize(rule)
    @rule = rule
  end

  def parse_and_process
    parser = Parser::ProductPageParser.new(@rule.url, timeout: @rule.waits_timeout, cookies: @rule.cookies)

    case parser.get_value(@rule.selector)
    in Success(parsed_price)
      handle_success(parsed_price)
    in Failure[String => error_message, *]
      handle_failure(error_message)
    end
  end

  private

  def handle_success(price_value)
    return if price_value.blank?

    RulesError.where(product_parser_rule: @rule).destroy_all

    product = @rule.product
    date_begining_for_period_min_price = product.period_lowest_price_in_days&.ago
    min_price_by_period = product.lowest_price(since: date_begining_for_period_min_price)

    last_price = product.prices.last
    create_price(price_value) if @rule.prices.blank? || price_value != last_price.value

    return unless need_notification?(min_price_by_period, price_value)

    Notifier::TelegramBot.low_price_notification(@rule, price_value)
  end

  def handle_failure(error_message)
    ErrorHandlingService.new(@rule, error_message).process
  end

  def create_price(value)
    Price.create(product_parser_rule: @rule, value:)
  end

  # Проверка, на сколько процентов уменьшилась цена
  def need_notification?(min_price_by_period, price_value)
    return false unless min_price_by_period

    price_decrease_percentage = (min_price_by_period - price_value.to_f) / min_price_by_period * 100
    price_decrease_percentage >= 5
  end
end
