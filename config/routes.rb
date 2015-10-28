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

  #### TESTING ONLY
  #### IF YOU ADD ITEMS HERE YOU BETTER ADD A GUARD SPEC!
  #### i.e. expect(get: '/memory_load').not_to be_routable
  # get '/memory_load', to: 'spree/api/testers#memory_load'
  #### TESTING ONLY

  post '/charges', to: 'spree/api/charges#charge'
  post '/factoryprebid', to: 'spree/api/prebids#factory_prebid'
  get 'accept/:bid_id', to: 'spree/auctions#auction_payment'
  post '/customer', to: 'spree/api/charges#create_customer'
  post '/delete_customer/:customer_id', to: 'spree/api/charges#delete_customer'
  
  resources :pxtaxrates,
    controller: 'spree/pxtaxrates',
    as: 'pxtaxrates'

  resources :pxusers,
    controller: 'spree/pxusers',
    as: 'pxusers'

  resources :pxaccounts,
    controller: 'spree/pxaccounts',
    as: 'pxaccounts'

  resources :auctions,
    controller: 'spree/auctions',
    as: 'auctions' do
      collection do
        post 'upload_proof'
      end
      member do
        get 'download_proof'
      end
    end

  resources :dashboards,
    controller: 'spree/dashboards',
    as: 'dashboards',
    only: [:index]

  resources :invoices,
    controller: 'spree/invoices',
    as: 'invoices',
    only: [:index, :show]

  resources :logos,
    controller: 'spree/logos',
    as: 'logos'

  resources :product_requests,
    controller: 'spree/product_requests',
    as: 'product_requests',
    only: [:create]

  scope :api do
    resources :auctions, controller: 'spree/api/auctions' do
      member do
        post 'tracking'
        post 'confirmed_delivery'
        get 'tracking_information'
        post 'approve_proof'
        post 'reject_proof'
      end
      resources :bids, controller: 'spree/api/bids' do
        post 'accept'
      end
    end
    resources :bids, controller: 'spree/api/bids', as: 'api_bids'
    match '/bids/:id/accept' => 'spree/api/bids#accept', via: :post
    resources :favorites, controller: 'spree/api/favorites', as: 'api_favorites'
    resources :messages, controller: 'spree/api/messages', as: 'api_messages'
    resources :prebids, controller: 'spree/api/prebids', as: 'api_prebids'
    resources :upcharges, controller: 'spree/api/upcharges', as: 'api_upcharges'
    resources :taxrates, controller: 'spree/api/taxrates', as: 'api_taxrates'
    resources :pxaddresses, controller: 'spree/api/pxaddresses', as: 'api_addresses'
    match '/pxaddresses/:id/type' => 'spree/api/pxaddresses#type', via: :post
    match '/auctions/:id/order_confirm' => 'spree/api/auctions#order_confirm', via: :post
    match '/auctions/:id/in_production' => 'spree/api/auctions#in_production', via: :post
    match '/auctions/:id/claim_payment' => 'spree/api/auctions#claim_payment', via: :post
    match '/auctions/:id/reject_order' => 'spree/api/auctions#reject_order', via: :post
    match '/auctions/:id/resolve_dispute' => 'spree/api/auctions#resolve_dispute', via: :post

    resources :request_ideas, controller: 'spree/api/request_ideas' do
      member do
        post 'sample_request'
      end
    end

    resources :product_requests, controller: 'spree/api/product_requests'
  end

  match 'product_requests/:request_idea_id/destroy' => 'spree/admin/product_requests#destroy_idea', via: :post
  match 'product_requests/:request_idea_id/update' => 'spree/admin/product_requests#update_idea', via: :post

  Spree::Core::Engine.routes.draw do
    namespace :admin do
      resources :product_requests do
        member do
          post 'generate_notification'
        end
      end
    end
  end

end
