# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'product_parser_rules/edit', type: :view do
  let(:product_parser_rule) do
    ProductParserRule.create!
  end

  before(:each) do
    assign(:product_parser_rule, product_parser_rule)
  end

  it 'renders the edit product_parser_rule form' do
    render

    assert_select 'form[action=?][method=?]', product_parser_rule_path(product_parser_rule), 'post' do
    end
  end
end
