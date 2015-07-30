Rails.application.routes.draw do
  # route used by new relic to monitor uptime fo app
  get '/ping', to: 'application#ping'

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

  resources :auctions,
    controller: 'spree/auctions',
    as: 'auctions'

  resources :dashboards,
    controller: 'spree/dashboards',
    as: 'dashboards',
    only: [:index]

  resources :invoices,
    controller: 'spree/invoices',
    as: 'invoices',
    only: [:index, :show]

  scope :api do
    resources :auctions, controller: 'spree/api/auctions' do
      resources :bids, controller: 'spree/api/bids' do
        post 'accept'
      end
    end
    resources :bids, controller: 'spree/api/bids', as: 'api_bids'
    match '/bids/:id/accept' => 'spree/api/bids#accept', via: :post
    resources :favorites, controller: 'spree/api/favorites', as: 'api_favorites'
    resources :logos, controller: 'spree/api/logos', as: 'api_logos'
    resources :messages, controller: 'spree/api/messages', as: 'api_messages'
    resources :prebids, controller: 'spree/api/prebids', as: 'api_prebids'
    resources :upcharges, controller: 'spree/api/upcharges', as: 'api_upcharges'
  end
end
