require 'rails_helper'

RSpec.describe DurationHumanizer do

  let(:now) { Time.current }

  def result(end_time)
    DurationHumanizer.to_string(RenderingHelper.new, now, end_time)
  end

  context 'when durarion greater than 2 days' do
    it 'shows highest measure rounded to the lower bound' do
      expect(result(now + 6.days + 20.hours)).to eq '6 days'
      expect(result(now + 6.days + 10.hours)).to eq '6 days'
    end
  end

  context 'when duration between 1 and 2 days' do
    it 'shows two highest measures' do
      expect(result(now + 1.days + 20.hours + 10.minutes)).to eq '1 day and 20 hours'
      expect(result(now + 1.days + 10.hours + 10.minutes)).to eq '1 day and 10 hours'
    end
  end

  context 'when duration less than a day' do
    it 'shows two highest measures' do
      expect(result(now + 20.hours + 40.minutes)).to eq '20 hours and 40 minutes'
      expect(result(now + 9.hours + 40.minutes + 20.seconds)).to eq '9 hours and 40 minutes'
    end
  end

end
