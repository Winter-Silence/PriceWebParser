# frozen_string_literal: true

class AddWailtsTimeOutToProductParserRules < ActiveRecord::Migration[7.0]
  def change
    add_column :product_parser_rules, :waits_timeout, :integer
  end
end
