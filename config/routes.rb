InteriorC::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  def draw_routes
    root 'home#index'

    resources :designers, only: [:new, :create, :update]

    resources :sessions, only: [] do
      collection do
        get 'logout'
        get 'designer_login'
        get 'client_login'
        post 'client_authenticate'
        post 'authenticate'
        match 'retry_password', via: [:post, :get]
        match 'client_retry_password', via: [:post, :get]
      end
    end

    get 'terms_of_service', to: 'home#terms_of_service'
    get 'faq', to: 'home#faq'
    get 'sign_up_beta', to: 'home#sign_up_beta'

    resources :contest_requests, only: [:show, :create] do
      member do
        post 'add_comment'
        get 'save_lookbook'
        post 'answer'
        post 'approve_fulfillment'
        get 'download'
      end
    end

    resources :contests, only: [:show, :update, :index] do
      member do
        get 'respond'
        get 'option'
        get 'show', as: 'show'
        get 'download_all_images_url'
        resources :feedback,
                  controller: 'reviewer_feedbacks',
                  as: 'reviewer_feedbacks',
                  only: [:create] do

          collection do
            get '', to: 'reviewer_feedbacks#show', as: 'show'
          end
        end
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

    resources :images, only: [:show, :create]

    resources :clients, only: [:create, :update]

    resources :client_center, only: [] do
      collection do
        get '', to: 'clients#client_center', as: ''
        get 'entries', to: 'clients#entries', as: 'entries'
        get 'concept_boards_page', to: 'clients#concept_boards_page', as: 'concept_boards_page'
        get 'brief', to: 'clients#brief', as: 'brief'
        get 'profile', to: 'clients#profile', as: 'profile'
        get 'pictures_dimension', to: 'clients#pictures_dimension'
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
        get 'updates', to: 'designer_center#updates', as: 'updates'
        get 'training', to: 'designer_center#training', as: 'training'
        resources :contests,
                  controller: 'designer_center_contests',
                  as: 'designer_center_contest',
                  only: [:show, :index] do
          collection do
            get 'index'
          end
        end
        resources :responses,
                  controller: 'designer_center_requests',
                  as: 'designer_center_response',
                  only: [:new, :create, :show, :index, :update, :edit] do
          get 'preview', on: :member,  as: 'preview'
        end
        resource :portfolio, only: [:edit, :update]
      end
    end



    resources :designer_invitations, only: [:create]
    resources :contest_notes, only: [:create]
    resources :reviewer_invitations, only: [:create]
    resources :beta_subscribers, only: [:create]
    resources :image_items, only: [:create, :update, :new, :edit, :destroy] do
      member do
        patch 'mark', to: 'image_items#mark', as: 'mark'
      end
      collection do
        get 'default', to: 'image_items#default', as: 'default'
      end
    end
    resource :designs do
      get '/:token', to: 'contest_requests#design', as: 'public'
    end
    resources :notifications, only: [:show] do
      collection do
        get '/comments/:id', to: 'notifications#show_comment', as: 'comment'
      end
    end

    resources :promocodes, only: [] do
      collection do
        get '', to: 'promocodes#apply', as: 'apply'
      end
    end

    get '/coming_soon', to: 'home#coming_soon', as: 'coming_soon'
    get '/:url', to: 'portfolios#show', as: 'show_portfolio'
  end

  if Rails.env.production? || Rails.env.development? || Rails.env.test?
    constraints subdomain: /^(www)?$/ do
      root 'home#sign_up_beta', as: 'beta_signup'
      get 'sign_up_beta', to: 'home#sign_up_beta'

      resources :beta_subscribers, only: [:create]
    end

    constraints subdomain: 'beta' do
      post '/create_beta_session', to: 'home#create_beta_session'
      get '/sign_in_beta', to: 'home#sign_in_beta', as: 'sign_in_beta'
      draw_routes
    end
  else
    draw_routes
  end

end
