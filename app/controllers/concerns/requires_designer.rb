module RequiresDesigner
  extend ActiveSupport::Concern

  def set_designer
    @designer = Designer.find(session[:designer_id]) if check_designer
  end

end
