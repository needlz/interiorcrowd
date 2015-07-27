class AnonymMenu < Menu

  def main_items
    common_menu role_specific_items
  end

  def mobile_items
    common_menu role_specific_items
  end

  private

  def role_specific_items
    { I18n.t('header.login') =>
          {
              I18n.t('header.client_login') => view_context.client_login_sessions_path,
              I18n.t('header.designer_login') => view_context.designer_login_sessions_path
          }
    }
  end

end
