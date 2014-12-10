Rails.application.routes.draw do

  apipie
  namespace :v1, defaults: {format: 'json'} do
    resources :users, except: [:new, :edit, :destroy, :update]
    resources :friendships, except: [:new, :edit],path: "friends", shallow: true
    resources :groups, except: [:new, :edit], shallow: true do
      resources :messages, except: [:new, :edit], shallow: true
    end
    post 'login', to: 'login#create'
    get 'profile', to: 'users#index'
    patch 'profile', to: 'users#update'
    put 'profile', to: 'users#update'
    get 'pending', to: 'friendships#index_pending'
  end
end
