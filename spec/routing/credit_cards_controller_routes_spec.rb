require "rails_helper"

RSpec.describe CreditCardsController do
  it 'routes PATCH request to change the primary card' do
    expect(patch: 'credit_cards/3/set_as_primary').to route_to(action: 'set_as_primary',
                                                               controller: 'credit_cards',
                                                               id: '3')
  end
end
