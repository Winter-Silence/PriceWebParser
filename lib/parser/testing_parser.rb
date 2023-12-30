# frozen_string_literal: true

module Parser
class TestingParser < BaseParser
  def take_screenshot
    load_page('div')
    super
  end
end
end
