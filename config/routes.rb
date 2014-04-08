InteriorC::Application.routes.draw do
  resources :designers

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  
  resources :sessions do
    collection do
      match 'logout', via: [:get] 
      match 'login', via: [:get]
       match 'authenticate', via: [:post]
    end   
  end
   
   root 'home#index'
   
   resources :contest_requests
   
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
   
   resources :documents
   resources :users
   
   resources :designers do
     member do
      match 'thank_you', via: [:get]
      match 'welcome', via: [:get]
     end 
   end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
