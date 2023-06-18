# frozen_string_literal: true

class SinglePageParserJob < ApplicationJob
  def perform(parse_now: false)
    products = Product.left_outer_joins(product_parser_rules: :prices)
                      .where(ProductParserRule.arel_table[:last_run].lt(30.minutes.ago)
                                                                    .or(ProductParserRule.arel_table[:last_run].eq(nil)))
    products.each do |product|
      product.product_parser_rules.each do |rule|
        rule.touch(:last_run)
        parse_now ? SinglePageRuleJob.perform_now(rule) : SinglePageRuleJob.perform_later(rule)
      end
    end
  end
end
