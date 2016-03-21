require 'rails_helper'

RSpec.describe HomeHelper do
  it 'returns all client stories' do
    expect(todays_client_stories.count).to equal I18n.t('home.client_stories.stories').count
  end

  it 'returns client story depending of the serial year day' do
    t = Time.local(2016, 1, 4, 10, 5, 0)
    Timecop.travel(t)
    expect(todays_client_stories.first[:name]).to eq 'Karsyn'
  end

  #TODO: add test for single @todays_client_stories instantiation
end