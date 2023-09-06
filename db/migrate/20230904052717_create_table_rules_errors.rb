# frozen_string_literal: true

class CreateTableRulesErrors < ActiveRecord::Migration[7.0]
  def change
    create_table :rules_errors do |t|
      t.belongs_to :product_parser_rule
      t.integer :error_type, null: false
      t.text :message
      t.timestamps

      t.foreign_key :product_parser_rules
    end
  end
end
