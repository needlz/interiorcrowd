require 'rails_helper'

RSpec.describe ScheduledNotifications::WarningAboutSubmissionEndClose do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:scheduler) { ScheduledNotifications::WarningAboutSubmissionEndClose }

  context 'one day left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 4.day + 1.minute)
    end
    it 'schedules mail' do
      scheduler.perform
      expect(jobs_with_handler_like('four_days_left_to_submit_concept_board').count).to eq 1
    end
  end

  context 'more than one day left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 5.days)
    end
    it 'does not schedule mail' do
      scheduler.perform
      expect(jobs_with_handler_like('four_days_left_to_submit_concept_board').count).to eq 0
    end
  end

  context 'less than one day left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 3.days)
    end
    it 'does not schedule mail' do
      scheduler.perform
      expect(jobs_with_handler_like('four_days_left_to_submit_concept_board').count).to eq 0
    end
  end

end
