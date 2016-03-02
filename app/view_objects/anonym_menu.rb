class AnonymMenu < Menu

  def main_items
    common_menu_with role_specific_items
  end

  def mobile_items
    common_menu_with role_specific_items
  end

  private

  def role_specific_items
    { I18n.t('header.login') =>
          {
              I18n.t('header.client_login') => view_context.new_client_session_path,
              I18n.t('header.designer_login') => view_context.new_designer_session_path
          }
    }
  end

end
