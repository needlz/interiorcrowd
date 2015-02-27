module ResponseButtons

  class ClosedButtons < Base

    def all
      [{ caption: I18n.t('designer_center.responses.item.view_moodboard'),
         href: designer_center_response_path(id: response_id) }]
    end

  end

end
