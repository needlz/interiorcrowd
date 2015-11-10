require 'rails_helper'

RSpec.describe Jobs::TimeConditionalNotifications do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:job) { Jobs::TimeConditionalNotifications.new }

  context 'when 4 days to the end of submission milestone' do
    before do
      contest.update_attributes!(phase_end: Time.current + 4.days + 20.minutes)
    end

    context 'when no concept boards submitted' do
      it 'notifies designers' do
        job.perform
        expect(jobs_with_handler_like(ScheduledNotifications::NoSubmissions.notification).count).to eq 1
        expect(jobs_with_handler_like(ScheduledNotifications::OneSubmission.notification).count).to eq 0
      end
    end

    context 'when one concept board submitted' do
      before do
        Fabricate(:contest_request, contest: contest, designer: Fabricate(:designer))
      end

      it 'notifies designers' do
        job.perform
        expect(jobs_with_handler_like(ScheduledNotifications::NoSubmissions.notification).count).to eq 0
        expect(jobs_with_handler_like(ScheduledNotifications::OneSubmission.notification).count).to eq 1
      end
    end

    context 'when more than one concept boards submitted' do
      before do
        Fabricate(:contest_request, contest: contest, designer: Fabricate(:designer))
        Fabricate(:contest_request, contest: contest, designer: Fabricate(:designer))
      end

      it 'does not notify designers' do
        job.perform
        expect(jobs_with_handler_like(ScheduledNotifications::NoSubmissions.notification).count).to eq 0
        expect(jobs_with_handler_like(ScheduledNotifications::OneSubmission.notification).count).to eq 0
      end
    end
  end

end
