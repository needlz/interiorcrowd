class ClientMenu < Menu

  def main_items
    specific_items =
      { I18n.t('header.client_center') => view_context.client_center_index_path,
        I18n.t('header.sign_out') => view_context.logout_sessions_path }
    common_menu(specific_items)
  end

  def mobile_items
    specific_items =
      { I18n.t('header.client_center') => Navigation::ClientCenter.new.to_mobile_menu,
        I18n.t('header.sign_out') => view_context.logout_sessions_path }
    common_menu(specific_items)
  end

  private

  def common_menu(specific_items)
    menu = MenuBuilder.new
    menu.append(I18n.t('header.for deisgners') => view_context.coming_soon_path)
    menu.append(I18n.t('header.get_inspired') => view_context.coming_soon_path)
    menu.append(I18n.t('header.blog') => ApplicationController::BLOG_URL)
    menu.append(specific_items)
    menu
  end

end
