require 'rails_helper'

RSpec.describe CommentNotifier do
  let(:comment) do
    contest_request.comments.create!(user_id: designer.id, role: designer.role, text: 'text of the comment')
  end
  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer) }

  def notify
    notifier = CommentNotifier.new(contest_request, author, comment)
    notifier.perform
  end

  context 'when submission milestone' do
    let(:contest) { Fabricate(:contest, status: 'submission', client: client) }

    context 'when comment has been made by client' do
      let(:author) { client }

      it 'schedules email with template "comment_on_board"' do
        notify
        expect(jobs_with_handler_like('comment_on_board').count).to eq 1
      end
    end

    context 'when comment has been made by designer' do
      let(:author) { designer }

      it 'schedules email with template "designer_asks_client_a_question_submission_phase"' do
        notify
        expect(jobs_with_handler_like('designer_asks_client_a_question_submission_phase').count).to eq 1
      end
    end
  end

  context 'winner_selection milestone' do
    let(:contest) { Fabricate(:contest, status: 'winner_selection', client: client) }

    context 'when comment has been made by client' do
      let(:author) { client }

      it 'schedules email with template "comment_on_board"' do
        notify
        expect(jobs_with_handler_like('comment_on_board').count).to eq 1
      end
    end

    context 'when comment has been made by designer' do
      let(:author) { designer }

      it 'schedules email with template "comment_on_board"' do
        notify
        expect(jobs_with_handler_like('comment_on_board').count).to eq 1
      end
    end
  end

end
