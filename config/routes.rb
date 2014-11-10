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
      get 'space_areas'
      post 'save_space_areas'
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
