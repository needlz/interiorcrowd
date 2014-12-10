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
      post 'answer'
    end
  end

  resources :contests do
    member do
      get 'respond'
      get 'option'
      patch 'update'
      get 'show', as: 'show'
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

  resources :clients

  resources :client_center, only: [] do
    collection do
      get '', to: 'clients#client_center', as: ''
      get 'entries', to: 'clients#entries', as: 'entries'
      get 'brief', to: 'clients#brief', as: 'brief'
      get 'profile', to: 'clients#profile', as: 'profile'
    end
  end

  resources :designers, only: [:create, :update] do
    member do
      get 'thank_you'
      get 'welcome'
      match 'lookbook', via: [:get, :post]
      get 'preview_lookbook'
    end
  end

  resources :designer_center, only: [] do
    collection do
      get '', to: 'designer_center#designer_center', as: ''
      get 'preview_contests', to: 'designer_center#contests_index', as: 'preview_contests'
      resource :portfolio, only: [:edit, :update, :new, :create]
    end
  end

  get '/:url', to: 'portfolios#show', as: 'show_portfolio'
end
