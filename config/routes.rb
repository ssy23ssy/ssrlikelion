Rails.application.routes.draw do

  devise_for :users
  root 'posts#index'
  resources :posts, except: [:index] do
    resources :comments, only: [:create, :destroy]
  end
  get '*unmatched_route' => 'application#not_found'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
