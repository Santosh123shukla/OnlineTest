Rails.application.routes.draw do
  resources :homes, only: [:index]

  # Defines the root path route ("/")
  root 'homes#index'

  resources :questions, only: [:new, :create] do
    collection do
      get 'download_template'
      get 'take_test'
      post 'submit_test'
    end
  end
end
