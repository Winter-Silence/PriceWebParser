# frozen_string_literal: true

require 'dry-monads'

module Parser
  class BaseParser
    include Dry::Monads[:result, :do]
    # TODO:
    # Нужно как-то фильтровать по заголовку товара, чтобы было именно то, по чему правило настроено. Например на озоне
    # на правило Karcher WzD3 вылезают Karcher WD2
    def initialize(url, timeout: nil, cookies: {})
      @timeout = timeout
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument('--headless')
      @driver = Webdriver::UserAgent.driver(browser: :chrome, agent: :desktop, orientation: :landscape, options:)
      if cookies.present?
        @driver.get(url)
        cookies.each do |name, value|
          @driver.manage.add_cookie(name:, value: value.to_s)
        end
      end

      @driver.navigate.to url
    end

    def get_value(selector)
      load_page(selector)

      value = @driver.find_element(:css, selector).text.gsub(/[^\d.,]/, '').to_f.to_i
      @driver.quit
      Success(value)
    rescue StandardError => e
      @driver.quit
      Failure(e.message)
    end

    private

    def load_page(selector)
      return Success unless @timeout.to_i.positive?

      @wait = Selenium::WebDriver::Wait.new(timeout: @timeout)
      @wait.until { @driver.find_element(:css, selector).displayed? }
      Success
    end
  end
end
