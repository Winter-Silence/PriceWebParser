# frozen_string_literal: true

class ErrorHandlingService
  def initialize(product_parser_rule, msg, error_threshold = 20)
    @product_parser_rule = product_parser_rule
    @msg = msg
    @error_threshold = error_threshold
  end

  def process
    rule_error = create_rule_error
    handle_error_notification(rule_error) if rule_error
  rescue StandardError => e
    Rails.logger.error e.message
  end

  private

  def create_rule_error
    rule_error_type = determine_error_type

    return if errors_count(rule_error_type) >= @error_threshold

    RulesError.create(product_parser_rule: @product_parser_rule, error_type: rule_error_type, message: @msg)
  end

  def determine_error_type
    cropped_text = @msg[..60]
    if cropped_text.include?('no such element:')
      :element_not_found
    else
      :unrecognized
    end
  end

  def handle_error_notification(rule_error)
    Notifier::TelegramBot.error_alert(rule_error)
  end
  
  def errors_count(error_type)
    @errors_count ||= RulesError.where(product_parser_rule: @product_parser_rule, error_type:).count
  end
end
