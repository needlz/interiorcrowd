require "rails_helper"

RSpec.describe TimeTrackerView do
  let(:hours_actual) { 10 }
  let(:hours_suggested) { 2 }
  let(:contest) { Fabricate(:contest) }
  let(:time_tracker) { Fabricate(:time_tracker, contest: contest, hours_actual: hours_actual, hours_suggested: hours_suggested) }
  let(:tracker_view) { TimeTrackerView.new(time_tracker) }

  it 'should have access to TimeTrackers contest, actual and suggested hours' do
    expect(tracker_view.contest).to be_present
    expect(tracker_view.hours_actual).to eql hours_actual
    expect(tracker_view.hours_suggested).to eql hours_suggested
  end

  it 'checks if some hours is suggested' do
    expect(tracker_view.suggested_hours?).to be_truthy
  end
end
