module ClientsHelper

  def active_tab_class(path)
    'active' if current_page?(path)
  end

  def navigation_links
    [{ name: 'Entries', path: entries_clients_path },
     { name: 'Brief',   path: brief_clients_path },
     { name: 'Profile', path: profile_clients_path }]
  end

end
