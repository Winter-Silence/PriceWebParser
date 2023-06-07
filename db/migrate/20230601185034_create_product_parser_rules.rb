# frozen_string_literal: true

class CreateProductParserRules < ActiveRecord::Migration[7.0]
  def change
    create_table :product_parser_rules do |t|
      t.belongs_to :product, foreign_key: true
      t.string :url, null: false
      t.string :selector, null: false
      t.boolean :active, default: true
      t.datetime :last_run
      t.timestamps
    end
  end
end
