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

  def main_menu(user_center_navigation)
    return @main_menu if @main_menu
    @main_menu = Menu.get(current_user: current_user,
                          view_context: self,
                          user_center_navigation: user_center_navigation).main_items
  end

  def mobile_menu(user_center_navigation)
    return @mobile_menu if @mobile_menu
    @mobile_menu = Menu.get(current_user: current_user,
                            view_context: self,
                            user_center_navigation: user_center_navigation).mobile_items
  end

  def share_button_parent_data(request, url)
    { data: { desc: '',
              popup: 'true',
              img: request.concept_board_current_image_path,
              title: 'my design',
              url: url } }
  end

  def css_url(url)
    "url('#{ j(url) }')"
  end

  def the_only_package
    BudgetPlan::PLANS[0]
  end

end
