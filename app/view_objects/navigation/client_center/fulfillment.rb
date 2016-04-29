class Navigation::ClientCenter::Fulfillment < Navigation::ClientCenter::Base
  def tabs
    {
        time_tracker: { name: I18n.t('client_center.navigation.time_tracker'),
                        href: time_tracker_client_center_entry_path(id: @contest.id) },
        design: { name: I18n.t('client_center.navigation.design'),
                  href: client_center_entry_path(id: @contest.id) },
        brief: { name: I18n.t('client_center.navigation.brief'),
                 href: brief_contest_path(id: @contest.id) },
        profile: { name: I18n.t('client_center.navigation.profile'),
                 href: client_center_profile_path }
    }
  end
end
