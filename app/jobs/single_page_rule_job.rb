# frozen_string_literal: true

class SinglePageRuleJob < ApplicationJob
  def perform(rule)
    SinglePageRuleParserService.new(rule).parse_and_process
  end
end
