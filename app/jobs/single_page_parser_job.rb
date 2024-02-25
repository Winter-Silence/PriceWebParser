# frozen_string_literal: true

class SinglePageParserJob < ApplicationJob
  def perform(parse_now: false)
    rules = ProductParserRule.only_active.includes(:prices)
                             .where(ProductParserRule.arel_table[:last_run].lt(2.hour.ago)
                                      .or(ProductParserRule.arel_table[:last_run].eq(nil)))
    rules.each do |rule|
      rule.touch(:last_run)
      parse_now ? SinglePageRuleJob.perform_now(rule) : SinglePageRuleJob.perform_later(rule)
    end
  end
end
