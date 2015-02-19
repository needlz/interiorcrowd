module ResponseButtons
  class SubmittedButtons < Base

    def all
      [{ caption: I18n.t('designer_center.responses.item.update_moodboard'),
         href: edit_designer_center_response_path(id: response_id) }]
    end

  end
end
