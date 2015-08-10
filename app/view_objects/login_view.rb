class LoginView
  def self.urls
    Rails.application.routes.url_helpers
  end

  def self.client_login
    {
        auth_path: urls.client_authenticate_sessions_path,
        forgot_password_path: urls.client_retry_password_sessions_path,
        title: I18n.t('login.client.title')
    }
  end

  def self.designer_login
    {
        auth_path: urls.authenticate_sessions_path,
        forgot_password_path: urls.designer_retry_password_sessions_path,
        title: I18n.t('login.designer.title')
    }
  end

end
