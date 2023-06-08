Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "products#index"
  resources :products
  get '/product_condition/:id', to: 'products#price_condition'
end
