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
      get 'step1'
      post 'save_step1'
      get 'step2'
      post 'save_step2'
      get 'step3'
      post 'save_step3'
      get 'step4'
      post 'save_step4'
      get 'preview'
      post 'save_step5'
      post 'upload'
      post 'step4_upload'
      get 'step6'
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
