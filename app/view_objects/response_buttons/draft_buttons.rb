module ResponseButtons

  class DraftButtons < Base

    def all
      [{ caption: I18n.t('designer_center.responses.item.update_moodboard'),
         href: edit_designer_center_response_path(id: response_id) },
       { caption: I18n.t('designer_center.responses.item.send_note'), href: '#' }]
    end

  end

end
