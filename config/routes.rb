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

  root :to => "company_store#index"

  post '/charges', to: 'spree/api/charges#charge'
  get 'accept/:order_id', to: 'spree/purchases#purchase_payment'
  get 'csaccept/:order_id', to: 'spree/purchases#csaccept'
  post '/customer', to: 'spree/api/charges#create_customer'
  post '/delete_customer/:customer_id', to: 'spree/api/charges#delete_customer'
  post '/confirm', to: 'spree/api/charges#confirm_deposit'
  post '/send_request', to: 'spree/home#send_request'

  get '/company_store', to: 'spree/company_store#index'
  get '/company_store/:id', to: 'spree/company_store#show'
  post '/inspire_me_request', to: 'spree/company_store#inspire_me'

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

  resources :dashboards, controller: 'spree/dashboards', as: 'dashboards', only: [:index]
  resources :invoices, controller: 'spree/invoices', as: 'invoices', only: [:index, :show]

  resources :logos,
    controller: 'spree/logos',
    as: 'logos' do
      member do
        get 'download_logo'
      end
    end

  resources :purchases,
    controller: 'spree/purchases',
    as: 'purchases',
    only: [:new, :create]

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
    resources :taxrates, controller: 'spree/api/taxrates', as: 'api_taxrates'
    post '/auctions/:id/order_confirm' => 'spree/api/auctions#order_confirm'
    post '/auctions/:id/in_production' => 'spree/api/auctions#in_production'
    post '/auctions/:id/claim_payment' => 'spree/api/auctions#claim_payment'
    post '/auctions/:id/reject_order' => 'spree/api/auctions#reject_order'
    post '/auctions/:id/resolve_dispute' => 'spree/api/auctions#resolve_dispute'
    get '/products/:id/best_price' => 'spree/api/products#best_price'

    resources :request_ideas, controller: 'spree/api/request_ideas' do
      member do
        post 'sample_request'
      end
    end

    resources :product_requests, controller: 'spree/api/product_requests'

    resources :charges, controller: 'spree/api/charges', only: [:index]
  end

  post 'product_requests/:request_idea_id/destroy' => 'spree/admin/product_requests#destroy_idea'
  post 'product_requests/:request_idea_id/update' => 'spree/admin/product_requests#update_idea'

  Spree::Core::Engine.routes.draw do
    namespace :admin do
      resources :product_requests do
        member do
          post 'generate_notification'
        end
      end
      resources :product_loads
      resources :pms_colors
      resources :imprint_methods
      resources :option_mappings
      resources :product_reports
      resources :upcharge_types
      resources :pms_colors_suppliers
      resources :suppliers do
        get :addresses
        put :addresses
        get :imprint_methods
        put :imprint_methods
      end
    end
  end

  Spree::Core::Engine.add_routes do
    namespace :admin do
      resources :products do
        resources :color_products
        resources :imprint_methods_products
        resources :upcharge_products
        resources :carton_products
      end
    end
  end
end
