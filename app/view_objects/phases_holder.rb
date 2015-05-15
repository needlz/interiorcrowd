class PhasesHolder

  attr_reader :phases_stripe

  def initialize
    @phases_stripe = create_phases_stripe
  end

  protected

  def create_phases_stripe
    raise NotImplementedError
  end

end
