# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'product_parser_rules/index', type: :view do
  before(:each) do
    assign(:product_parser_rules, [
             ProductParserRule.create!,
             ProductParserRule.create!
           ])
  end

  it 'renders a list of product_parser_rules' do
    render
    Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
  end
end
