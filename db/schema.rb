# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 20_230_601_185_555) do
  create_table 'prices', force: :cascade do |t|
    t.integer 'product_parser_rules_id'
    t.integer 'price', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['product_parser_rules_id'], name: 'index_prices_on_product_parser_rules_id'
  end

  create_table 'product_parser_rules', force: :cascade do |t|
    t.integer 'product_id'
    t.string 'url', null: false
    t.string 'selector', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['product_id'], name: 'index_product_parser_rules_on_product_id'
  end

  create_table 'products', force: :cascade do |t|
    t.string 'title', null: false
    t.string 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  add_foreign_key 'prices', 'product_parser_rules', column: 'product_parser_rules_id'
  add_foreign_key 'product_parser_rules', 'products'
end
