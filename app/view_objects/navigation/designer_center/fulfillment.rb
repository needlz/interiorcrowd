class Navigation::DesignerCenter::Fulfillment < Navigation::DesignerCenter::Base

  def tabs
    if @contest_request
      {
        time_tracker: { name: I18n.t('designer_center.navigation.time_tracker'),
                        href: designer_center_contest_time_tracker_path(contest_id: @contest.id)},
        design: { name: I18n.t('designer_center.navigation.design'),
                  href: edit_designer_center_response_path(id: @contest_request.id)},
        brief: { name: I18n.t('designer_center.navigation.brief'),
                 href: designer_center_contest_path(id: @contest.id) }
      }
    else
      {
        brief: { name: I18n.t('designer_center.navigation.brief'),
                 href: designer_center_contest_path(id: @contest.id) }
      }
    end

  end

end
