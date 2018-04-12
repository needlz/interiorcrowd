class Menu

  def initialize(options)
    @current_user = options[:current_user]
    @view_context = options[:view_context]
    @user_center_navigation = options[:user_center_navigation]
  end

  def self.get(options)
    menu_class = "#{ options[:current_user].role }Menu".constantize
    menu_class.new(options)
  end

  protected

  def common_menu_with(specific_items)
    menu = MenuBuilder.new
    menu.append({ I18n.t('header.how_it_works') => view_context.how_it_works_path }, { target: '_blank' })
    menu.append({ I18n.t('header.blog') => view_context.blog_root_path })
    menu.append(specific_items)
    menu
  end

  private

  attr_reader :current_user, :view_context

end
