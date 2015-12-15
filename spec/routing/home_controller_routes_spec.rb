require "rails_helper"

RSpec.describe HomeController do
  it 'routes GET #how_it_works request to "How It Works" page' do
    expect(get: 'how_it_works').to route_to(action: 'how_it_works',
                                            controller: 'home')
  end

  it 'routes GET #about_us request to "About Us" page' do
    expect(get: 'about_us').to route_to(action: 'about_us',
                                        controller: 'home')
  end
end
