class DesignerMenu < Menu

  def main_items
    specific_items =
        { I18n.t('header.designer_center') => view_context.designer_center_index_path,
          I18n.t('header.sign_out') => view_context.logout_sessions_path }
    common_menu(specific_items)
  end

  def mobile_items
    specific_items =
        { I18n.t('header.designer_center') => Navigation::DesignerCenter.new.to_mobile_menu,
          I18n.t('header.sign_out') => view_context.logout_sessions_path }
    common_menu(specific_items)
  end

  private

  def common_menu(specific_items)
    menu = MenuBuilder.new(I18n.t('header.get_inspired') => view_context.coming_soon_path)
    if current_user.portfolio_path
      menu.append(I18n.t('header.portfolio') => view_context.show_portfolio_path(current_user.portfolio_path))
    end
    menu.append(I18n.t('header.how_it_works') => view_context.coming_soon_path)
    menu.append(specific_items)
    menu
  end

end
