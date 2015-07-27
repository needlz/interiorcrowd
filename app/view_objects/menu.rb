class Menu

  def initialize(current_user, view_context)
    @current_user = current_user
    @view_context = view_context
  end

  def self.get(current_user, view_context)
    menu_class = "#{ current_user.role }Menu".constantize
    menu_class.new(current_user, view_context)
  end

  protected

  def common_menu_for(specific_items)
    menu = MenuBuilder.new
    menu.append(I18n.t('header.for_designers') => view_context.coming_soon_path)
    menu.append(I18n.t('header.get_inspired') => 'http://blog.interiorcrowd.com/category/get-ideas')
    menu.append(I18n.t('header.blog') => ApplicationController::BLOG_URL)
    menu.append(specific_items)
    menu
  end

  private

  attr_reader :current_user, :view_context

end
