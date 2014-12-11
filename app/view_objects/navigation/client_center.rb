module Navigation

  class ClientCenter < Base
    def tabs
      {
        entries: { name: I18n.t('client_center.navigation.entries'),
          href: entries_client_center_index_path },
        brief: { name: I18n.t('client_center.navigation.brief'),
          href: brief_client_center_index_path},
        profile: { name: I18n.t('client_center.navigation.profile'),
          href: profile_client_center_index_path}
      }
    end
  end
end
