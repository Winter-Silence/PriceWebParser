# frozen_string_literal: true

module Notifier
  class TelegramBot
    def self.low_price_notification(rule, price_value)
      text = "Для #{rule.product.title} цена понизилась до #{price_value}"
      Telegram.bot.send_message(chat_id: Rails.application.credentials.telegram[:chat_id], text:)
    end
  end
end
