module Navigation

  class ClientCenter < Base
    def tabs
      {
        entries: { name: I18n.t('client_center.navigation.entries'),
          href: client_center_entries_path },
        brief: { name: I18n.t('client_center.navigation.brief'),
          href: client_center_brief_path},
        profile: { name: I18n.t('client_center.navigation.profile'),
          href: client_center_profile_path}
      }
    end
  end
end
