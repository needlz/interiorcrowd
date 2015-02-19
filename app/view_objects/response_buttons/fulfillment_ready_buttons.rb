module ResponseButtons
  class FulfillmentReadyButtons < Base

    def all
      [{ caption: I18n.t('designer_center.responses.item.update_moodboard'),
         href: edit_designer_center_response_path(id: response_id) },
       { caption: I18n.t('designer_center.responses.item.create_shopping_list'), href: '#' },
       { caption: I18n.t('designer_center.responses.item.create_3d_rendering'), href: '#' },
       { caption: I18n.t('designer_center.responses.item.send_note'), href: '#' }]
    end

  end
end
