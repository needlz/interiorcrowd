module DesignerCenterHelper

  def designer_center_active_tab_class(path)
    'active' if current_page?(path)
  end

  def designer_center_navigation_links
    [{ name: t('designer_center.navigation.create_portfolio'), path: edit_portfolio_path }]
  end

end
