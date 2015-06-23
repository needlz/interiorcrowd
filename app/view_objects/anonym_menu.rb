class AnonymMenu < Menu

  def main_items
    common_menu
  end

  def mobile_items
    common_menu
  end

  private

  def common_menu
    menu = MenuBuilder.new(I18n.t('header.get_inspired') => view_context.coming_soon_path)
    menu.append(I18n.t('header.how_it_works') => view_context.coming_soon_path)
    menu.append({ I18n.t('header.login') =>
                      {
                          I18n.t('header.client_login') => view_context.client_login_sessions_path,
                          I18n.t('header.designer_login') => view_context.designer_login_sessions_path
                      }
                }
    )
    menu
  end

end
