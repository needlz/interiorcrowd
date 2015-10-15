require 'rails_helper'

RSpec.describe SubmitContest do

  let(:client) { Fabricate(:client, primary_card: Fabricate(:credit_card)) }
  let(:submit_contest) { SubmitContest.new(contest) }

  context 'when contest created with space pictures' do
    let(:contest) do
      contest_creation = ContestCreation.new(client_id: client.id, contest_params: contest_options_source, make_complete: true)
      contest = contest_creation.perform
      contest
    end

    context 'when real payments disabled' do
      before do
        allow(Settings).to receive(:payment_enabled){ false }
      end

      it 'submits contest on creation' do
        contest
        expect(contest.status).to eq 'submission'
      end
    end

    context 'on staging server' do
      before do
        allow(Settings).to receive(:payment_enabled){ true }
      end

      it 'does not submit contest on creation' do
        contest
        expect(contest.status).to eq 'brief_pending'
      end
    end
  end

  context 'when contest created without space pictures' do
    let(:contest_options) do
      options = contest_options_source()
      options[:design_space].merge(document_id: '')
      options
    end
    let(:contest) do
      contest_creation = ContestCreation.new(client_id: client.id, contest_params: contest_options, make_complete: true)
      contest = contest_creation.perform
      contest
    end

    context 'when real payments enabled' do
      before do
        allow(Settings).to receive(:payment_enabled){ true }
      end

      context 'when contest payed' do
        before do
          pay_contest(contest)
        end

        it 'delays client notification about concept boards not received' do
          submit_contest.try_perform
          job_delay = jobs_with_handler_like('CheckIfBoardsReceived').first.run_at - 3.days - Time.current
          expect(job_delay.abs < 1).to be_truthy
        end
      end

      context 'when contest not payed' do
        it 'does not submit contest' do
          submit_contest.try_perform
          expect(submit_contest.performed?).to be_falsey
          contest.reload
          expect(contest.status).to eq 'brief_pending'
        end
      end
    end
  end

end
