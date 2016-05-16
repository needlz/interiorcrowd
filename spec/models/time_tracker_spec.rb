require 'rails_helper'

RSpec.describe TimeTracker, type: :model do
  context 'when creating new time tracker' do
    let(:time_tracker) { Fabricate(:time_tracker) }

    it 'already has default values for suggested_hours and actual_hours' do
      expect(time_tracker.hours_suggested).to eq (0)
      expect(time_tracker.hours_actual).to eq(0)
    end

    it 'doesn\'t save negative suggested hours' do
      expect{time_tracker.update_attributes!(hours_suggested: -10)}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'saves positive suggested hours amount' do
      expect{time_tracker.update_attributes!(hours_suggested: 10)}.to change{time_tracker.hours_suggested}.from(0).to(10)
    end

  end
end
