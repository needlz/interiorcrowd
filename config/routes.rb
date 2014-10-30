InteriorC::Application.routes.draw do
  resources :designers

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  
  resources :sessions do
    collection do
      match 'logout', via: [:get] 
      match 'login', via: [:get]
      match 'client_login', via: [:get]
      match 'client_authenticate', via: [:post]
      match 'authenticate', via: [:post]
      match 'retry_password', via: [:post, :get]
      match 'client_retry_password', via: [:post, :get]
    end   
  end
   
   root 'home#index'
   
   resources :contest_requests do
     member do
       match 'save_lookbook', via:[:get]
     end
   end
   
   resources :contests do
     member do
      match 'respond', via: [:get]
   end
     
     collection do
       match 'step1', via: [:get, :post]
       match 'step2', via: [:get, :post]
       match 'step3', via: [:get, :post]
       match 'step4', via: [:get, :post]
       match 'preview', via: [:get, :post]
       match 'upload', via: [:post]
       match 'step4_upload', via: [:post]
       match 'step6', via: [:post, :get]
       match 'thank_you', via: [:get]
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
      match 'thank_you', via: [:get]
      match 'welcome', via: [:get]
      match 'lookbook', via: [:get, :post]
      match 'preview_lookbook', via: [:get]
     end 
   end
end
