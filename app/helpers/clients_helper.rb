module ClientsHelper

  def active_tab_class(path)
    'active' if current_page?(path)
  end

  def navigation_links
    [{ name: 'Entries', path: entries_client_center_index_path },
     { name: 'Brief',   path: brief_client_center_index_path },
     { name: 'Profile', path: profile_client_center_index_path }]
  end

  def profile_rows
    [
      { title: 'First name', attribute: 'first_name' },
      { title: 'Last name', attribute: 'last_name' },
      { title: 'Email', attribute: 'email' },
      { title: 'Address', attribute: 'address' },
      { title: 'Billing information', attribute: 'billing_info' }
    ]
  end

end
