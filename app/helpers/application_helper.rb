module ApplicationHelper

  def translations_to_json(sections)
    @translator = I18n.backend
    @translator.load_translations
    if sections.present?
      if sections.kind_of?(Array)
        @translations = @translator.send(:translations)[I18n.locale]
        sections.each do |section|
          @translations = @translations[section.to_sym]
        end
      else
        @translations = @translator.send(:translations)[I18n.locale][sections.to_sym]
      end
    else
      @translations = @translator.send(:translations)[I18n.locale]
    end
    @translations.to_json.html_safe
  end

  def for_each_by_groups(array, group_size, &block)
    total_index = 0
    content = ''
    array.in_groups_of(group_size, false) do |group|
      group.each_with_index do |item, group_index|
        block[item, group_index, total_index]
        total_index += 1
      end
    end
    content.html_safe
  end

  def mobile_menu
    return @links if @links
    @links = MobileMenu.new(t('header.get_inspired') => coming_soon_path)

    if current_user.designer? && current_user.portfolio_path
      @links.append(t('header.portfolio') => show_portfolio_path(current_user.portfolio_path))
    end

    @links.append(t('header.how_it_works') => coming_soon_path)

    if current_user.designer?
      @links.append({ t('header.designer_center') => Navigation::DesignerCenter.new.to_mobile_menu,
                      t('header.sign_out') => logout_sessions_path })
    elsif current_user.client?
      @links.append({ t('header.client_center') => Navigation::ClientCenter.new.to_mobile_menu,
                      t('header.sign_out') => logout_sessions_path })
    else
      @links.append({ t('header.login') => {
          t('header.client_login') => client_login_sessions_path,
          t('header.designer_login') => designer_login_sessions_path
      } })
    end
    @links
  end

end
