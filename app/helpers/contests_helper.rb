module ContestsHelper

  def contest_creation_category_radiobutton(category)
    radio_button_tag 'design_brief[design_category]',
                     category.id,
                     @creation_wizard.design_categories_checkboxes[category.id],
                     class: "design_element regular-radio big-radio"
  end

  def color_table_values
    [{ text: 'Black 6', id: 'ffffff' },
     { text: 'Black 5', id: 'bcbcbc' },
     { text: 'Black 4', id: 'a7a8aa' },
     { text: 'Black 3', id: '898b8e' },
     { text: 'Black 2', id: '53565a' },
     { text: 'Black 1', id: '1d252d' },

     { text: 'Ivory 6', id: 'fcfcf4' },
     { text: 'Ivory 5', id: 'f9f9ea' },
     { text: 'Ivory 4', id: 'f6f6df' },
     { text: 'Ivory 3', id: 'dcdcc6' },
     { text: 'Ivory 2', id: 'abab9a' },
     { text: 'Ivory 1', id: '626258' },

     { text: 'Brown 6', id: 'ddc7b7' },
     { text: 'Brown 5', id: 'caa892' },
     { text: 'Brown 4', id: 'ae7f66' },
     { text: 'Brown 3', id: '955e3a' },
     { text: 'Brown 2', id: '643511' },
     { text: 'Brown 1', id: '502c1d' },

     { text: 'Yellow 6', id: 'fae08e' },
     { text: 'Yellow 5', id: 'fdd873' },
     { text: 'Yellow 4', id: 'ffc945' },
     { text: 'Yellow 3', id: 'ffb81b' },
     { text: 'Yellow 2', id: 'ecab00' },
     { text: 'Yellow 1', id: 'b78500' },

     { text: 'Orange 6', id: 'ffba90' },
     { text: 'Orange 5', id: 'ffa169' },
     { text: 'Orange 4', id: 'ff8030' },
     { text: 'Orange 3', id: 'ff6c11' },
     { text: 'Orange 2', id: 'db6116' },
     { text: 'Orange 1', id: 'a95522' },

     { text: 'Red 6', id: 'fcbccb' },
     { text: 'Red 5', id: 'ff9cb2' },
     { text: 'Red 4', id: 'fb5474' },
     { text: 'Red 3', id: 'eb002a' },
     { text: 'Red 2', id: 'ce112d' },
     { text: 'Red 1', id: 'ab1a2d' },

     { text: 'Blue 6', id: 'b8d8eb' },
     { text: 'Blue 5', id: '9acbec' },
     { text: 'Blue 4', id: '66b2e7' },
     { text: 'Blue 3', id: '0078ca' },
     { text: 'Blue 2', id: '0065a2' },
     { text: 'Blue 1', id: '004054' },

     { text: 'Green 6', id: '9abdab' },
     { text: 'Green 5', id: '86af9b' },
     { text: 'Green 4', id: '6fa188' },
     { text: 'Green 3', id: '297150' },
     { text: 'Green 2', id: '215b41' },
     { text: 'Green 1', id: '294635' }]
  end

  def force_link_protocol(link)
    return '' unless link.present?
    link =~ /^https?\:/ ? link : "http://#{ link }"
  end

  def get_link_base_url(link)
    base = URI(force_link_protocol(link))
    "#{ base.scheme }://#{ base.host }"
  rescue URI::InvalidURIError
    link
  end

end
