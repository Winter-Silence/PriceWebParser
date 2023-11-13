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
end
