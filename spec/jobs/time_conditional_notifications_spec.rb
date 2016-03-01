require 'rails_helper'

RSpec.describe Jobs::TimeConditionalNotifications do

  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client, status: 'submission') }
  let(:contest_request) { Fabricate(:contest_request, contest: contest) }
  let(:job) { Jobs::TimeConditionalNotifications.new }

  context 'when 4 days to the end of submission milestone' do
    before do
      contest.update_attributes!(phase_end: Time.current +
                                     ScheduledNotifications::NoSubmissions.period_before_milestone_end +
                                     Jobs::TimeConditionalNotifications.interval/2)
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

  context 'when there is contest request' do
    let!(:client) { Fabricate(:client) }
    let!(:designer) { Fabricate(:designer) }
    let!(:contest) { Fabricate(:contest, status: 'submission', client: client) }
    let!(:request_visited) { Fabricate(:contest_request, contest: contest, last_visit_by_client_at: Time.current - 5.days, designer: designer) }

    context 'without designer comment 3 days ago after client visited contest' do
      let!(:comment_4_days_ago_by_client) { ConceptBoardCommentCreation.new(request_visited, { text: 'text', created_at: Time.current - 4.days }, client).perform }
      let!(:comment_2_days_ago_by_designer) { ConceptBoardCommentCreation.new(request_visited, { text: 'text', created_at: Time.current - 2.days }, client).perform }

      it 'does not remind client about designer awaiting feedback' do
        expect(ScheduledNotifications::DesignerWaitingFeedback.scope).to match_array([])
        job.perform
        expect(jobs_with_handler_like(ScheduledNotifications::DesignerWaitingFeedback.notification).count).to eq 0
      end
    end

    context 'with designer comment 3 days ago after client visited contest' do
      let!(:comment_4_days_ago_by_client) { ConceptBoardCommentCreation.new(request_visited, { text: 'text', created_at: Time.current - 4.days }, client).perform }
      let!(:comment_2_days_ago_by_designer) { ConceptBoardCommentCreation.new(request_visited, { text: 'text', created_at: Time.current - 2.days }, client).perform }
      let!(:comment_3_days_ago_by_designer) { ConceptBoardCommentCreation.new(request_visited, { text: 'text', created_at: Time.current - 3.days }, designer).perform }
      let!(:client_2) { Fabricate(:client) }
      let!(:client_3) { Fabricate(:client) }
      let!(:client_4) { Fabricate(:client) }
      let!(:contest_2) { Fabricate(:contest, client: client_2, status: 'submission') }
      let!(:contest_3) { Fabricate(:contest, client: client_3, status: 'submission') }
      let!(:contest_4) { Fabricate(:contest, client: client_3, status: 'submission') }
      let!(:request_not_visited) { Fabricate(:contest_request, contest: contest_2, last_visit_by_client_at: nil, designer: designer) }
      let!(:request_visited_2) { Fabricate(:contest_request, contest: contest_3, last_visit_by_client_at: Time.current - 5.days, designer: designer) }
      let!(:request_visited_fulfillment) do
        request = Fabricate(:contest_request,
                            contest: contest_4,
                  last_visit_by_client_at: Time.current - 5.days,
                  designer: designer,
                  answer: 'winner',
                  status: 'fulfillment_ready')
        contest_4.update_attributes!(status: 'fulfillment')
        request
      end
      let!(:comment_4_days_ago_by_designer) { ConceptBoardCommentCreation.new(request_visited, { text: 'text', created_at: Time.current - 4.days }, designer).perform }
      let!(:comment_more_than_3_days_ago_by_designer) { ConceptBoardCommentCreation.new(request_visited_2, { text: 'text', created_at: Time.current - 3.days - (Jobs::TimeConditionalNotifications.interval / 2) }, designer).perform }
      let!(:comment_less_than_3_days_ago_by_designer) { ConceptBoardCommentCreation.new(request_visited_2, { text: 'text', created_at: Time.current - 3.days + (Jobs::TimeConditionalNotifications.interval / 2) }, designer).perform }
      let!(:comment_after_last_visit) { ConceptBoardCommentCreation.new(request_visited_fulfillment, { text: 'text', created_at: Time.current - 6.days }, designer).perform }

      def notification_params_by_comment(comment)
        contest = comment.contest_request.contest
        client = contest.client
        [client, [contest.id]]
      end

      it 'reminds client about designer awaiting feedback' do
        expected_notifications_params =
          [comment_4_days_ago_by_designer,
           comment_3_days_ago_by_designer,
           comment_more_than_3_days_ago_by_designer].map(&:contest_request).map(&:contest).uniq.group_by(&:client).map do |client, contests|
            [client, contests.map(&:id)]
          end
        expect(ScheduledNotifications::DesignerWaitingFeedback.scope).to match_array(expected_notifications_params)
        clients_to_notify_count = ScheduledNotifications::DesignerWaitingFeedback.scope.length
        job.perform
        expect(jobs_with_handler_like(ScheduledNotifications::DesignerWaitingFeedback.notification).count).to eq 0
      end
    end
  end

end
