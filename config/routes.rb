Rails.application.routes.draw do
  # route used by new relic to monitor uptime fo app
  get '/ping', to: 'application#ping'

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

  get '/api/messages', to: 'spree/api/messages#index', defaults: {format: 'json'}
  get '/api/messages/:id', to: 'spree/api/messages#show', defaults: {format: 'json'}
  post '/api/messages', to: 'spree/api/messages#create', defaults: {format: 'json'}
  put '/api/messages/:id', to: 'spree/api/messages#update', defaults: {format: 'json'}
  delete '/api/messages/:id', to: 'spree/api/messages#destroy', defaults: {format: 'json'}

  get '/api/auctions', to: 'spree/api/auctions#index', defaults: {format: 'json'}
  get '/api/auctions/:id', to: 'spree/api/auctions#show', defaults: {format: 'json'}
  post '/api/auctions', to: 'spree/api/auctions#create', defaults: {format: 'json'}
  put '/api/auctions/:id', to: 'spree/api/auctions#update', defaults: {format: 'json'}
  delete '/api/auctions/:id', to: 'spree/api/auctions#destroy', defaults: {format: 'json'}

  get '/api/auctions/:id/bids', to: 'spree/api/bids#index', defaults: {format: 'json'}
  get '/api/auctions/:id/bids/:id', to: 'spree/api/bids#show', defaults: {format: 'json'}
  post '/api/auctions/:id/bids', to: 'spree/api/bids#create', defaults: {format: 'json'}
  put '/api/auctions/:id/bids/:id', to: 'spree/api/bids#update', defaults: {format: 'json'}
  delete '/api/auctions/:id/bids/:id', to: 'spree/api/bids#destroy', defaults: {format: 'json'}

  get '/api/bids', to: 'spree/api/bids#index', defaults: {format: 'json'}
  get '/api/bids/:id', to: 'spree/api/bids#show', defaults: {format: 'json'}
  post '/api/bids', to: 'spree/api/bids#create', defaults: {format: 'json'}
  put '/api/bids/:id', to: 'spree/api/bids#update', defaults: {format: 'json'}
  delete '/api/bids/:id', to: 'spree/api/bids#destroy', defaults: {format: 'json'}

  get '/api/prebids', to: 'spree/api/prebids#index', defaults: {format: 'json'}
  get '/api/prebids/:id', to: 'spree/api/prebids#show', defaults: {format: 'json'}
  post '/api/prebids', to: 'spree/api/prebids#create', defaults: {format: 'json'}
  put '/api/prebids/:id', to: 'spree/api/prebids#update', defaults: {format: 'json'}
  delete '/api/prebids/:id', to: 'spree/api/prebids#destroy', defaults: {format: 'json'}
end
