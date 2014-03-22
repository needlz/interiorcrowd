# Be sure to restart your server when you modify this file.

InteriorC::Application.config.session_store :cookie_store, key: '_interior_c_session'

#ActionController::Dispatcher.middleware.insert_before(ActionController::Base.session_store, FlashSessionCookieMiddleware, ActionController::Base.session_options[:key])
Rails.application.config.middleware.insert_before(
      ActionDispatch::Session::CookieStore,
      FlashSessionCookieMiddleware,
      Rails.application.config.session_options[:key]
    )