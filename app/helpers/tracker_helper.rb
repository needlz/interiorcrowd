module TrackerHelper

  def hidden_mixpanel_submit_tag
    submit_tag '', class: 'hidden'
  end

  def tracked_link
    'tracked-link'
  end

end
