InteriorC::Application.routes.draw do

  if Rails.env.production?
    root 'home#sign_up_beta'
    get 'sign_up_beta', to: 'home#sign_up_beta'
    resources :beta_subscribers, only: [:create]
  else
    resources :designers, only: [:new, :create, :update]

    resources :sessions, only: [] do
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

    get 'faq', to: 'home#faq'
    get 'sign_up_beta', to: 'home#sign_up_beta'
    root 'home#index'

    resources :contest_requests, only: [:show, :create] do
      member do
        get 'save_lookbook'
        post 'answer'
      end
    end

    resources :contests, only: [:show, :update, :index] do
      member do
        get 'respond'
        get 'option'
        get 'show', as: 'show'
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

    get '/:url', to: 'portfolios#show', as: 'show_portfolio'

    resources :designer_invitations, only: [:create]
    resources :contest_notes, only: [:create]
    resources :reviewer_invitations, only: [:create]
    resources :beta_subscribers, only: [:create]
  end
end
