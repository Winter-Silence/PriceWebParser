# frozen_string_literal: true

json.extract! product_parser_rule, :id, :created_at, :updated_at
json.url product_parser_rule_url(product_parser_rule, format: :json)
