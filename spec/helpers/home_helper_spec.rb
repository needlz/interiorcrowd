require 'rails_helper'

RSpec.describe HomeHelper do
  before do
    mock_client_stories_locales
  end

  it 'returns all client stories' do
    expect(todays_client_stories.count).to equal I18n.t('home.client_stories.stories').count
  end

  it 'returns first client story on January 6, 2016' do
    time = Time.local(2016, 1, 6, 10, 5, 0)
    Timecop.travel(time)

    expect(todays_client_stories.first[:name]).to eq 'First'
  end

  it 'returns third client story on June 12, 2016' do
    time = Time.local(2016, 6, 12, 10, 5, 0)
    Timecop.travel(time)

    expect(todays_client_stories.first[:name]).to eq 'Third'
  end

  it 'returns fifth client story on December 17, 2016' do
    time = Time.local(2016, 12, 17, 10, 5, 0)
    Timecop.travel(time)

    expect(todays_client_stories.first[:name]).to eq 'Fifth'
  end
end
