# frozen_string_literal: true

module Parser
  class BaseParser
    # TODO:
    # сделать кнопку для принудительного запуска парсера, чтобы отладить селектор
    # сделать галку у правила, чтобы можно было деактивировать его
    def initialize(url)
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      @driver = Webdriver::UserAgent.driver(browser: :chrome, agent: :desktop, orientation: :landscape, options:)
      @driver.navigate.to url
    end

    def get_value(selector)
      Rails.logger.debug @driver.find_element(:css, selector).text
      value = @driver.find_element(:css, selector).text.gsub(/[^\d.,]/, '').to_f.to_i
      @driver.quit
      value
    rescue StandardError => e
      @driver.quit
      e.message
    end
  end
end
