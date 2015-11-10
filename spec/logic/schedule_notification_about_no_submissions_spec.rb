require 'rails_helper'

RSpec.describe ScheduledNotifications::NoSubmissions do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:scheduler) { ScheduledNotifications::NoSubmissions }

  context 'four days left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 4.days + 1.minute)
    end
    it 'schedules mail' do
      scheduler.perform
      expect(jobs_with_handler_like(ScheduledNotifications::NoSubmissions.notification.to_s).count).to eq 1
    end
  end

  context 'more than four days left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 5.days)
    end
    it 'does not schedule mail' do
      scheduler.perform
      expect(jobs_with_handler_like(ScheduledNotifications::NoSubmissions.notification.to_s).count).to eq 0
    end
  end

  context 'less than four days left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 6.hours)
    end
    it 'does not schedule mail' do
      scheduler.perform
      expect(jobs_with_handler_like(ScheduledNotifications::NoSubmissions.notification.to_s).count).to eq 0
    end
  end

end
