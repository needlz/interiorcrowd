class TestHelperBase

  def initialize(controller, session)
    @controller = controller
    @session = session
  end

  protected

  attr_reader :session, :controller

end
