module ApplicationHelper

  def translations_to_json(sections)
    @translator = I18n.backend
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

  def title(pagename)
    result = "#{ pagename } - InteriorCrowd"
    content_for(:title) { result }
  end

  def new_contest_path
    design_brief_contests_path
  end

  def page_title
    content_for?(:title) ? content_for(:title) : 'InteriorCrowd'
  end

  def page_description
    content_for?(:description) ? content_for(:description) : page_title
  end

  def file_uploading_form(locales, &block)
    form_content = capture(&block) if block
    render 'shared/file_upload_form', locales.merge(form_content: form_content)
  end

end
