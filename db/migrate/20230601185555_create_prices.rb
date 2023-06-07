# frozen_string_literal: true

class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices do |t|
      t.integer :product_parser_rule_id
      t.integer :value, null: false

      t.timestamps

      t.index :product_parser_rule_id
    end
    add_foreign_key :prices, :product_parser_rules
  end
end
