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

  def message_name(user, comment)
    if comment.role == user.class.name
      'Me' #user.name
    else
      comment.role
    end

  end
end
