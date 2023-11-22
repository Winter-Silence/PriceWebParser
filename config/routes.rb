# frozen_string_literal: true

Rails.application.routes.draw do
  resources :product_parser_rules do
    get :check, on: :member
  end
  resources :products do
    resources :product_parser_rules, only: %i[index new create]
    get :prices_chart, on: :member
  end
  get 'show_screenshot', to: 'product_parser_rules#show_screenshot'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'products#index'

  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking
    # (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username),
                                                ::Digest::SHA256.hexdigest('parserkiq')) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password),
                                                  ::Digest::SHA256.hexdigest('sidepasskiq'))
  end
  mount Sidekiq::Web => '/sidekiq'
end
