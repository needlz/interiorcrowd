InteriorC::Application.routes.draw do
  resources :designers

  resources :sessions do
    collection do
      get 'logout'
      get 'login'
      get 'client_login'
      post 'client_authenticate'
      post 'authenticate'
      match 'retry_password', via: [:post, :get]
      match 'client_retry_password', via: [:post, :get]
    end
  end

  root 'home#index'

  resources :contest_requests do
    member do
      get 'save_lookbook'
    end
  end

  resources :contests do
    member do
      get 'respond'
    end

    collection do
      get 'design_brief'
      post 'save_design_brief'
      get 'design_style'
      post 'save_design_style'
      get 'design_space'
      post 'save_design_space'
      get 'preview'
      post 'save_preview'
      post 'upload'
      get 'account_creation'
      get 'thank_you'
    end
  end

  resources :images

  resources :clients do
    collection do
      get 'client_center'
      get 'client_center/entries', to: 'clients#entries', as: 'entries'
      get 'client_center/brief', to: 'clients#brief', as: 'brief'
      get 'client_center/profile', to: 'clients#profile', as: 'profile'
    end
  end

  resources :designers do
    member do
      get 'thank_you'
      get 'welcome'
      match 'lookbook', via: [:get, :post]
      get 'preview_lookbook'
    end
  end
end
