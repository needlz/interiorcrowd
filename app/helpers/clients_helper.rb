module ClientsHelper

  def active_tab_class(path)
    'active' if current_page?(path)
  end

  def navigation_links
    [{ name: 'Entries', path: entries_clients_path },
     { name: 'Brief',   path: brief_clients_path },
     { name: 'Profile', path: profile_clients_path }]
  end

  def brief_fields
    [
      { option: 'category', option_partial: 'contests/categories_preview' },
      { option: 'area', option_partial: 'contests/areas_preview' },
      { option: 'appeals', option_partial: 'contests/appeals_preview' },
      { option: 'desirable_colors', option_partial: 'contests/desirable_colors_preview' },
      { option: 'undesirable_colors', option_partial: 'contests/undesirable_colors_preview' },
      { option: 'example_pictures', option_partial: 'contests/examples_preview' },
      { option: 'example_links', option_partial: 'contests/links_preview' },
      { option: 'space_pictures', option_partial: 'contests/space_pictures_preview' },
      { option: 'space_dimensions', option_partial: 'contests/dimensions_preview' },
      { option: 'budget', option_partial: 'contests/budget_preview' },
      { option: 'feedback', option_partial: 'contests/comment_preview' },
    ]
  end

end
