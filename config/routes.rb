Rails.application.routes.draw do
  resources :kegs do
    member do
      get 'renew'
    end
  end
  resources :drinks
  resources :users do
    member do
      get 'lost'
    end
  end
  root :to => redirect("/users")
  resources :operations do
    collection do
      get 'add'
      get 'exchange'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
