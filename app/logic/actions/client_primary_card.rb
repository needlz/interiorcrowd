class ClientPrimaryCard
  attr_reader :saved
  alias_method :saved?, :saved

  def initialize(user)
    @user = user
    @saved = nil
  end

  def set(new_card_id)
    @user.primary_card = @user.credit_cards.find new_card_id
    @saved = @user.save
  end

end
