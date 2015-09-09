module Navigation

  class ClientCenter < Base
    def tabs(contest = nil)
      brief_path = contest ? brief_contest_path(id: contest.id) : client_center_entries_path
      {
        entries: { name: I18n.t('client_center.navigation.entries'),
          href: client_center_entries_path },
        brief: { name: I18n.t('client_center.navigation.brief'),
          href: brief_path},
        profile: { name: I18n.t('client_center.navigation.profile'),
          href: client_center_profile_path}
      }
    end
  end
end
