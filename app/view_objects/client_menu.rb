class ClientMenu < Menu

  def main_items
    specific_items =
      { I18n.t('header.client_center') => view_context.client_center_path,
        I18n.t('header.sign_out') => view_context.logout_sessions_path }
    common_menu_with specific_items
  end

  def mobile_items
    specific_items =
      { I18n.t('header.client_center') => Navigation::ClientCenter.new.to_mobile_menu,
        I18n.t('header.sign_out') => view_context.logout_sessions_path }
    common_menu_with specific_items
  end

end
