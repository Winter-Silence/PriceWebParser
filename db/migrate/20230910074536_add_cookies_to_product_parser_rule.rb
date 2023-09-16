class AddCookiesToProductParserRule < ActiveRecord::Migration[7.0]
  def change
    add_column :product_parser_rules, :cookies, :jsonb, null: false, default: {}
  end
end
