Rails.application.routes.draw do
  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :products

  namespace :api do
    namespace :v1 do
      resources :products
    end
  end

  use_doorkeeper
end
