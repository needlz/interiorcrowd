class Menu

  def initialize(current_user, view_context)
    @current_user = current_user
    @view_context = view_context
  end

  def self.get(current_user, view_context)
    menu_class = "#{ current_user.role }Menu".constantize
    menu_class.new(current_user, view_context)
  end

  private

  attr_reader :current_user, :view_context

end
