# frozen_string_literal: true

class TelegramBot
  def self.low_price_notification(rule, price)
    text = "Для #{rule.product.title} цена понизилась до #{price.value}"
    Telegram.bot.send_message(chat_id: Rails.application.credentials.telegram[:chat_id], text:)
  end
end
