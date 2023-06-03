# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'product_parser_rules/show', type: :view do
  before(:each) do
    assign(:product_parser_rule, ProductParserRule.create!)
  end

  it 'renders attributes in <p>' do
    render
  end
end
