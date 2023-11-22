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
      @timeout = timeout || 5
      @cookies = cookies
      @url = url
      options = Selenium::WebDriver::Options.chrome(args: ['--headless=new', '--disable-blink-features=AutomationControlled',
                                                           'user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'])
      @driver = Webdriver::UserAgent.driver(browser: :chrome, orientation: :landscape, options:)
      set_cookies

      @driver.navigate.to url
    end

    def get_value(selector)
      load_page(selector)

      value = @driver.find_element(:css, selector).text.gsub(/[^\d.,]/, '').to_f.to_i
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
