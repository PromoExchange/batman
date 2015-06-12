Rails.application.routes.draw do
  # route used by new relic to monitor uptime fo app
  get '/ping', to: 'application#ping'

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

  scope '/api' do
    scope '/messages' do
      get '/', to: 'spree/api/messages#index', defaults: {format: 'json'}
      get '/:id', to: 'spree/api/messages#show', defaults: {format: 'json'}
      post '/', to: 'spree/api/messages#create', defaults: {format: 'json'}
      put '/:id', to: 'spree/api/messages#update', defaults: {format: 'json'}
      delete '/:id', to: 'spree/api/messages#destroy', defaults: {format: 'json'}
    end

    scope '/auctions' do
      get '/', to: 'spree/api/auctions#index', defaults: {format: 'json'}
      get '/:id', to: 'spree/api/auctions#show', defaults: {format: 'json'}
      post '/', to: 'spree/api/auctions#create', defaults: {format: 'json'}
      put '/:id', to: 'spree/api/auctions#update', defaults: {format: 'json'}
      delete '/:id', to: 'spree/api/auctions#destroy', defaults: {format: 'json'}

      get '/:id/bids', to: 'spree/api/bids#index', defaults: {format: 'json'}
      get '/:id/bids/:id', to: 'spree/api/bids#show', defaults: {format: 'json'}
      post '/:id/bids', to: 'spree/api/bids#create', defaults: {format: 'json'}
      put '/:id/bids/:id', to: 'spree/api/bids#update', defaults: {format: 'json'}
      delete '/:id/bids/:id', to: 'spree/api/bids#destroy', defaults: {format: 'json'}
    end

    scope '/bids' do
      get '/', to: 'spree/api/bids#index', defaults: {format: 'json'}
      get '/:id', to: 'spree/api/bids#show', defaults: {format: 'json'}
      post '/', to: 'spree/api/bids#create', defaults: {format: 'json'}
      put '/:id', to: 'spree/api/bids#update', defaults: {format: 'json'}
      delete '/:id', to: 'spree/api/bids#destroy', defaults: {format: 'json'}
    end

    scope '/prebids' do
      get '/', to: 'spree/api/prebids#index', defaults: {format: 'json'}
      get '/:id', to: 'spree/api/prebids#show', defaults: {format: 'json'}
      post '/', to: 'spree/api/prebids#create', defaults: {format: 'json'}
      put '/:id', to: 'spree/api/prebids#update', defaults: {format: 'json'}
      delete '/:id', to: 'spree/api/prebids#destroy', defaults: {format: 'json'}
    end

    scope '/upcharges' do
      get '/', to: 'spree/api/upcharges#index', defaults: {format: 'json'}
      get '/:id', to: 'spree/api/upcharges#show', defaults: {format: 'json'}
      post '/', to: 'spree/api/upcharges#create', defaults: {format: 'json'}
      put '/:id', to: 'spree/api/upcharges#update', defaults: {format: 'json'}
      delete '/:id', to: 'spree/api/upcharges#destroy', defaults: {format: 'json'}
    end
  end
end
