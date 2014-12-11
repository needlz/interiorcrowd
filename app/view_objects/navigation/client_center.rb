module Navigation

  class ClientCenter < Base
    def tabs
      [ { name: I18n.t('client_center.navigation.entries'),
          routes: [{ controller: 'clients', action: 'entries' },
                   { controller: 'contest_requests', action: 'show' }],
          href: view_context.entries_client_center_index_path },
        { name: I18n.t('client_center.navigation.brief'),
          routes: [{ controller: 'clients', action: 'brief' }],
          href: view_context.brief_client_center_index_path},
        { name: I18n.t('client_center.navigation.profile'),
          routes: [{ controller: 'clients', action: 'profile' }],
          href: view_context.profile_client_center_index_path}]
    end
  end
end
