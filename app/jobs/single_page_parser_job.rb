# frozen_string_literal: true

class SinglePageParserJob < ApplicationJob
  def perform(parse_now: false)
    current_time = Time.now
    threshold_time = current_time - 30.minutes
    products = Product.includes(product_parser_rules: :prices)
                      .where(product_parser_rules: { last_run: ..threshold_time })
    products.each do |product|
      product.product_parser_rules.each do |rule|
        rule.touch(:last_run)
        parse_now ? SinglePageRuleJob.perform_now(product, rule) : SinglePageRuleJob.perform_async(product, rule)
      end
    end
  end
end
