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

end
