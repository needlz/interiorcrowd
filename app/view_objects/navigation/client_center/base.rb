class Navigation::ClientCenter::Base < Navigation::Base
  def initialize(active_tab_or_options = nil, options = nil)
    if active_tab_or_options.kind_of? Hash
      options = active_tab_or_options
    end
    if options
      @contest = options[:contest]
    end
  end

  def tabs
    brief_path = @contest ? brief_contest_path(id: @contest.id) : client_center_entries_path
    {
        entries: { name: I18n.t('client_center.navigation.entries'),
                   href: client_center_entries_path },
        brief: { name: I18n.t('client_center.navigation.brief'),
                 href: brief_path },
        profile: { name: I18n.t('client_center.navigation.profile'),
                   href: client_center_profile_path}
    }
  end
end