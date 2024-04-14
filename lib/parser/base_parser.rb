# frozen_string_literal: true

require 'dry-monads'

module Parser
  class BaseParser
    include Dry::Monads[:result, :do]
    SCREENSHOTS_PATH = 'tmp/screenshots/rules'

    # TODO:
    # Нужно как-то фильтровать по заголовку товара, чтобы было именно то, по чему правило настроено. Например на озоне
    # на правило Karcher WzD3 вылезают Karcher WD2
    def initialize(url, timeout: nil, cookies: {})
      @timeout = timeout
      @cookies = cookies
      @url = url
      options = Selenium::WebDriver::Options.chrome
      options.add_argument('--headless=new')
      options.add_argument('--disable-blink-features=AutomationControlled')
      options.add_argument('--window-size=1920,1080')
      @driver = Webdriver::UserAgent.driver(browser: :chrome, orientation: :landscape, options:)
      set_cookies

      @driver.navigate.to url
    end

    def get_value(selector)
      load_page(selector)

      value = @driver.find_element(:css, selector).text.gsub(/[^\d.,]/, '').to_f.to_i
      raise StandardError, 'неверное значение цены' if value < 10

      Success(value)
    rescue StandardError => e
      screenshot_file_name = yield take_screenshot
      Failure([e.message, screenshot_file_name])
    ensure
      @driver.quit
    end

    def take_screenshot
      FileUtils.mkdir_p(SCREENSHOTS_PATH)
      file_name = "#{Time.current.strftime('%d.%m-%Y_%H.%M.%S')}.png"
      @driver.manage.window.resize_to(1024, 768)
      @driver.save_screenshot(File.join(SCREENSHOTS_PATH, file_name))
      Success(file_name)
    end

    private

    def load_page(selector)
      return Success unless @timeout.to_i.positive?

      @wait = Selenium::WebDriver::Wait.new(timeout: @timeout)
      @wait.until { @driver.find_element(:css, selector).displayed? }
      Success
    end

    def set_cookies
      return if @cookies.blank?

      @driver.get(@url)
      @cookies.each do |name, value|
        @driver.manage.add_cookie(name:, value: value.to_s)
      end
    end
  end
end
