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
      { option: 'category', option_partial: 'contests/previews/categories_preview' },
      { option: 'area', option_partial: 'contests/previews/areas_preview' },
      { option: 'appeals', option_partial: 'contests/previews/appeals_preview' },
      { option: 'desirable_colors', option_partial: 'contests/previews/desirable_colors_preview' },
      { option: 'undesirable_colors', option_partial: 'contests/previews/undesirable_colors_preview' },
      { option: 'example_pictures', option_partial: 'contests/previews/examples_preview' },
      { option: 'example_links', option_partial: 'contests/previews/links_preview' },
      { option: 'space_pictures', option_partial: 'contests/previews/space_pictures_preview' },
      { option: 'space_dimensions', option_partial: 'contests/previews/dimensions_preview' },
      { option: 'budget', option_partial: 'contests/previews/budget_preview' },
      { option: 'feedback', option_partial: 'contests/previews/comment_preview' },
    ]
  end

end
