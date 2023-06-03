# frozen_string_literal: true

class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices do |t|
      t.belongs_to :product_parser_rules, foreign_key: true
      t.integer :price, null: false

      t.timestamps
    end
  end
end
