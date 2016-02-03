require 'rails_helper'

RSpec.describe SubmitContest do

  let(:client) { Fabricate(:client) }
  let(:submit_contest) { SubmitContest.new(contest) }

  context 'when contest has space pictures' do
    let(:contest) do
      contest_creation = ContestCreation.new(client_id: client.id, contest_params: contest_options_source, make_complete: true)
      contest = contest_creation.perform
      contest
    end

    context 'when automatic payments disabled' do
      before do
        allow(Settings).to receive(:payment_enabled){ false }
      end

      context 'when the client has no primary card' do
        before do
          contest
          submit_contest.try_perform
        end

        it 'does not submit contest' do
          expect(contest).to be_brief_pending
        end
      end

      context 'when the client has primary card' do
        before do
          contest
          client.primary_card = Fabricate(:credit_card)
          client.save!
          submit_contest.try_perform
        end

        it 'submits contest' do
          expect(contest).to be_submission
        end
      end
    end

    context 'when automatic payments enabled' do
      before do
        allow(Settings).to receive(:payment_enabled){ true }
        contest
      end

      it 'does not submit contest on creation' do
        expect(contest.status).to eq 'brief_pending'
      end

      context 'contest was payed' do
        before do
          allow(contest).to receive(:payed?){ true }
        end

        it 'submits contest' do
          submit_contest.try_perform
          expect(submit_contest.performed?).to be_truthy
          contest.reload
          expect(contest.status).to eq 'submission'
        end

        it 'delays client notification about concept boards not received' do
          submit_contest.try_perform
          job_delay = jobs_with_handler_like('CheckIfBoardsReceived').first.run_at - 3.days - Time.current
          expect(job_delay.abs < 1).to be_truthy
        end

        it 'saves date of submission start' do
          submit_contest.try_perform
          expect(contest.reload.submission_started_at).to be_within(5.seconds).of(Time.current)
        end

        it 'discards the transaction when contest has incorrect status' do
          contest.update_attributes(status: 'submission')
          submit_contest.try_perform
          expect(submit_contest.performed?).to be_falsey
          expect(contest.reload.submission_started_at).to be_nil
          expect(jobs_with_handler_like('new_project_on_the_platform').count).to eq 0
        end

        it 'sends the email notification' do
          submit_contest.try_perform
          expect(jobs_with_handler_like('new_project_on_the_platform').count).to eq 1
        end
      end
    end
  end

  context 'when has no space pictures' do
    let(:contest_options) do
      options = contest_options_source()
      options[:design_space].merge!(document_id: '')
      options
    end
    let(:contest) do
      contest_creation = ContestCreation.new(client_id: client.id, contest_params: contest_options, make_complete: true)
      contest = contest_creation.perform
      contest
    end

    context 'when automatic payments enabled' do
      before do
        allow(Settings).to receive(:payment_enabled){ true }
      end

      context 'when contest payed' do
        before do
          client.primary_card = Fabricate(:credit_card)
          client.save!
          pay_contest(contest)
        end

        it 'does not submit contest' do
          expect{ submit_contest.try_perform }.to_not change{ contest.status }
          expect(submit_contest).to_not be_performed
        end

        it 'notifies client about contest not yet live' do
          notifications_created_on_contest_creation_count = 1
          expect(jobs_with_handler_like('contest_not_live_yet').count).to eq notifications_created_on_contest_creation_count
          expect{ submit_contest.try_perform }.to_not(change{ jobs_with_handler_like('contest_not_live_yet').count })
        end
      end

      context 'when contest not payed' do
        it 'does not submit contest' do
          expect{ submit_contest.try_perform }.to_not change{ contest.status }
          expect(submit_contest).to_not be_performed
        end
      end
    end

    context 'when automatic payments disabled' do
      before do
        allow(Settings).to receive(:payment_enabled){ false }
      end

      context 'when contest payed' do
        before do
          client.primary_card = Fabricate(:credit_card)
          client.save!
          pay_contest(contest)
        end

        it 'does not submit contest' do
          submit_contest.try_perform
          expect(submit_contest.performed?).to be_falsey
          contest.reload
          expect(contest.status).to eq 'brief_pending'
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
