# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductParserRulesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/product_parser_rules').to route_to('product_parser_rules#index')
    end

    it 'routes to #new' do
      expect(get: '/product_parser_rules/new').to route_to('product_parser_rules#new')
    end

    it 'routes to #show' do
      expect(get: '/product_parser_rules/1').to route_to('product_parser_rules#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/product_parser_rules/1/edit').to route_to('product_parser_rules#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/product_parser_rules').to route_to('product_parser_rules#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/product_parser_rules/1').to route_to('product_parser_rules#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/product_parser_rules/1').to route_to('product_parser_rules#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/product_parser_rules/1').to route_to('product_parser_rules#destroy', id: '1')
    end
  end
end
