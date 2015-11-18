require 'rails_helper'

RSpec.describe ScheduledNotifications::WarningAboutSubmissionEnd do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:scheduler) { ScheduledNotifications::WarningAboutSubmissionEnd }

  context 'one day left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 1.day + 1.minute)
    end
    it 'schedules mail' do
      scheduler.perform
      expect(jobs_with_handler_like('one_day_left_to_submit_concept_board').count).to eq 1
    end
  end

  def expect_not_schedule_mail
    scheduler.perform
    expect(jobs_with_handler_like('one_day_left_to_choose_a_winner').count).to eq 0
  end

  context 'more than one day left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 2.days)
    end

    it 'does not schedule mail' do
      expect_not_schedule_mail
    end
  end

  context 'less than one day left' do
    before do
      contest.update_attributes!(phase_end: Time.current + 6.hours)
    end

    it 'does not schedule mail' do
      expect_not_schedule_mail
    end
  end

end
