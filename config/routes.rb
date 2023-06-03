# frozen_string_literal: true

Rails.application.routes.draw do
  resources :product_parser_rules
  resources :products do
    resources :product_parser_rules, only: [:new, :create]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'products#index'
end
