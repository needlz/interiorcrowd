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
        get 'client_fb_authenticate'
        post 'authenticate'
        match 'designer_retry_password', via: [:post, :get]
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

    resources :contests, only: [:show, :update] do
      member do
        get 'option'
        get 'show', as: 'show'
        get 'brief', to: 'clients#brief', as: 'brief'
        get 'download_all_images_url'
        get 'design_brief'
        post 'save_design_brief'
        get 'design_style'
        post 'save_design_style'
        get 'design_space'
        post 'save_design_space'
        get 'preview'
        post 'save_preview'
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
        get 'payment_details'
        get 'payment_summary'
        put 'save_intake_form'
      end
    end

    resources :images, only: [:show, :create]

    resources :clients, only: [:create, :update] do
      collection do
        get 'validate_card'
        post 'sign_up_with_facebook'
        post 'sign_up_with_email'
        get 'unsubscribe/:signature', to: 'clients#unsubscribe', as: 'unsubscribe'
      end
    end

    scope '/client_center' do
      resources :entries, only: [:index, :show], controller: 'contests', as: 'client_center_entries'
      get '', to: 'clients#client_center', as: 'client_center'
      get 'concept_boards_page', to: 'clients#concept_boards_page', as: 'client_center_concept_boards_page'
      get 'profile', to: 'clients#profile', as: 'client_center_profile'
      get 'pictures_dimension', to: 'clients#pictures_dimension', as: 'client_center_pictures_dimension'
    end

    resources :designers, only: [:create, :update]

    scope '/designer_center' do
      get '', to: 'designer_center#designer_center', as: 'designer_center'
      get 'updates', to: 'designer_center#updates', as: 'designer_center_updates'
      get 'training', to: 'designer_center#training', as: 'designer_center_training'
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
        member do
          get 'preview', as: 'preview'
          patch 'publish', as: 'publish'
        end

        resources :lookbook_details, only: [:create, :destroy]
      end
      resource :portfolio, only: [:edit, :update]
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

    resources :lookbook_details, only: [] do
      collection do
        get '/preview', to: 'lookbook_details#preview', as: 'preview'
        delete '/remove_preview', to: 'lookbook_details#remove_preview', as: 'remove_preview'
      end
    end

    resources :final_note_to_designer,
              controller: 'final_note_to_designer',
              as: 'final_note_to_designer',
              only: [:create]

    resources :credit_cards, only: [:create, :edit, :update, :destroy] do
      member do
        patch 'set_as_primary'
      end
    end

    resources :client_payments, only: [:create]

    get '/coming_soon', to: 'home#coming_soon', as: 'coming_soon'
    get '/privacy_policy', to: 'home#privacy_policy', as: 'privacy_policy'
    get '/designer_submission', to: 'blog#designer_submission', as: 'designer_submission'
    get '/justines_story', to: 'blog#justines_story', as: 'justines_story'
    get '/about_us', to: 'blog#about_us', as: 'about_us'

    scope '/blog' do
      get '/:blog_page_path',
          to: 'blog#blog_page',
          as: 'blog_page',
          constraints: { blog_page_path: /.*/ }
      post '/:blog_page_post_path',
           to: 'blog#blog_page_post',
           as: 'blog_page_post',
           constraints: { blog_page_post_path: /.*/ }
      get '/', to: 'blog#blog_root', as: 'blog_root'
    end

    resource :outbound_email, :controller => 'outbound_emails', :only => [:show, :create]

    get '/sfar', to: 'rieltor_contacts#sfar', as: 'sfar'
  end

  def consider_rest_of_routes_as_portfolios
    get '/:url', to: 'portfolios#show', as: 'show_portfolio'
  end

  draw_routes
  consider_rest_of_routes_as_portfolios

end
