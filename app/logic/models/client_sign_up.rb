class ClientSignUp

  def initialize(params, session = nil)
    @params = params
    @session = session
  end

  protected

  attr_reader :params, :session

end
