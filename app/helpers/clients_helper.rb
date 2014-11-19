module ClientsHelper

  def active_tab_class(path)
    'active' if current_page?(path)
  end

end
