require 'rails_helper'

RSpec.describe ScheduledNotifications::DesignerWaitingFeedback do

  let(:client) { Fabricate(:client) }

  describe '#send_notification' do
    it 'updates last_remind_about_feedback_at of client' do
      ScheduledNotifications::DesignerWaitingFeedback.send_notification([client, []])
      expect(client.last_remind_about_feedback_at).to be_within(1.second).of(Time.current)
    end
  end
end
