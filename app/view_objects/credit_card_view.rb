class CreditCardView

  delegate :name_on_card, :card_type, :last_4_digits, :ex_month, :ex_year,
           :address, :city, :state, :zip, :id, to: :credit_card

  def initialize(credit_card)
    @credit_card = credit_card
  end

  def params
    {
      I18n.t('client_center.sign_up.credit_card.name') => name_on_card,
      I18n.t('client_center.sign_up.credit_card.number') => card_number,
      I18n.t('client_center.sign_up.credit_card.exp_date') => expiration_date,
      I18n.t('client_center.sign_up.credit_card.address') => full_address
    }
  end

  def card_number
    if card_type.present?
      "#{ card_type.capitalize } ending in #{ last_4_digits }"
    else
      "Ending in #{ last_4_digits }"
    end
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

  def link_caption
    primary? ? I18n.t('client_center.sign_up.primary_card') : I18n.t('client_center.sign_up.make_card_primary')
  end

  def self.year_select
    { :start_year => Time.now.year,
      :end_year => Time.now.year + 10,
      :field_name => :ex_year,
      prefix: 'credit_card',
      prompt: I18n.t('client_center.sign_up.select_year')}
  end

  def primary?
    credit_card == credit_card.client.primary_card
  end

  private

  attr_reader :credit_card

end
