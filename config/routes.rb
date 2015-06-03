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
  
end
