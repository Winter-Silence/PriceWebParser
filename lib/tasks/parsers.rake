# frozen_string_literal: true

namespace :parsers do
  desc 'Collects prices from the specified pages of each product'
  task parse_single_page: :environment do
    SinglePageParserJob.perform_now(parse_now: true)
  end

  desc 'Проверка условий парсера'
  task parse_rule: :environment do
    rule = ProductParserRule.find 20
    SinglePageRuleJob.perform_now(rule)
  end

  desc 'Сделать скрин страницы'
  task :take_screenshot, [:url, :timeout] => :environment do |_t, args|
    abort('url is blank') if args.url.blank?

    parser = Parser::BaseParser.new(args.url, timeout: args.timeout)
    screenshot_file_name = parser.take_screenshot.value!
    pp Rails.application.routes.url_helpers.show_screenshot_url(file_name: screenshot_file_name, only_path: true)
  end
end
