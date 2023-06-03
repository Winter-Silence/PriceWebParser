# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'product_parser_rules/new', type: :view do
  before(:each) do
    assign(:product_parser_rule, ProductParserRule.new)
  end

  it 'renders new product_parser_rule form' do
    render

    assert_select 'form[action=?][method=?]', product_parser_rules_path, 'post' do
    end
  end
end
