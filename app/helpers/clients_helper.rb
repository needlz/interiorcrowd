module ClientsHelper

  def client_center_active_tab_class(path)
    'active' if current_page?(path)
  end

  def client_center_navigation_links
    [{ name: 'Entries', path: entries_client_center_index_path },
     { name: 'Brief',   path: brief_client_center_index_path },
     { name: 'Profile', path: profile_client_center_index_path }]
  end

  def profile_rows
    ['first_name', 'last_name', 'email', 'address', 'billing_information']
  end

end
