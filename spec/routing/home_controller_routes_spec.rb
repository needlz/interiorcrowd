require "rails_helper"

RSpec.describe HomeController do
  it 'routes GET request to "How It Works" page' do
    expect(get: 'how_it_works').to route_to(action: 'how_it_works',
                                            controller: 'home')
  end
end
