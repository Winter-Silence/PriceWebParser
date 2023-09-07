# frozen_string_literal: true

module Notifier
  class TelegramBot
    class << self
      def low_price_notification(rule, price_value)
        text = "Для #{rule.product.title} цена понизилась до #{price_value}. #{rule.url}"
        Telegram.bot.send_message(chat_id: Rails.application.credentials.telegram[:chat_id], text:)
      end

      def error_alert(rule_error)
        product_title = rule_error.product_parser_rule.product.title
        rule_edit_page_url = Rails.application.routes.url_helpers.product_parser_rule_url(
          rule_error.product_parser_rule, only_path: false, host: Rails.application.credentials[:host]
        )
        text = "У '#{product_title}' по правилу #{rule_edit_page_url} много ошибок типа '#{rule_error.error_type}'"
        Telegram.bot.send_message(chat_id: Rails.application.credentials.telegram[:chat_id], text:)
      end
    end
  end
end
