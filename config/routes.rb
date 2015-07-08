Rails.application.routes.draw do
  # route used by new relic to monitor uptime fo app
  get '/ping', to: 'application#ping'

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

  resources :auctions, controller: 'spree/auctions', as: 'auctions' do
    get 'accept_bid'
  end

  resources :dashboards, controller: 'spree/dashboards', as: 'dashboards'

  scope :api do
    resources :messages, controller: 'spree/api/messages', as: 'api_messages'
    resources :auctions, controller: 'spree/api/auctions' do
      resources :bids, controller: 'spree/api/bids'
    end
    resources :bids, controller: 'spree/api/bids'
    resources :prebids, controller: 'spree/api/prebids', as: 'api_prebids'
    resources :upcharges, controller: 'spree/api/upcharges', as: 'api_upcharges'
    resources :favorites, controller: 'spree/api/favorites', as: 'api_favorites'
  end
end
