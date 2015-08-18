class CreditCardView

  delegate :name_on_card, :card_type, :last_4_digits, :ex_month, :ex_year,
           :address, :city, :state, :zip, :id, to: :credit_card

  def initialize(credit_card)
    @credit_card = credit_card
  end

  def params
    {
      'Name on card' => name_on_card,
      'Credit card' => card_number,
      'Expiration date' => expiration_date,
      'Address' => full_address
    }
  end

  def card_number
    "#{ card_type } ending in #{ last_4_digits }"
  end

  def full_address
    "#{ address }, #{ city } #{ state }"
  end

  def expiration_date
    "#{ ex_month } / #{ ex_year }"
  end

  def css_class
    primary? ? 'primary-card-params' : nil
  end

  private

  attr_reader :credit_card

  def primary?
    credit_card == credit_card.client.primary_card
  end

end
