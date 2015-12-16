require 'rails_helper'

RSpec.describe ContestCreation do

  let(:client) { Fabricate(:client, primary_card: Fabricate(:credit_card)) }

  context 'when contest expected to be complete' do
    let(:contest_creation) do
      ContestCreation.new(client_id: client.id,
                          contest_params: params,
                          make_complete: true)
    end

    context 'when contest payed' do
      context 'when space images set' do
        let(:params) { contest_options_source }
        let!(:contest) { contest_creation.perform }

        before do
          pay_contest(contest)
        end

        it 'sets contest state to submission' do
          expect(contest.status).to eq 'submission'
          expect(contest.phase_end).to be_present
        end

        it 'does not send email about brief pending' do
          expect(jobs_with_handler_like('contest_not_live_yet').count).to eq 0
        end

        it 'stores information if the contest was in brief_pending state ever' do
          expect(contest.reload.was_in_brief_pending_state).to be_falsey
        end
      end

      context 'when space images empty' do
        let(:params) { contest_options_source.deep_merge({design_space: { document_id: nil }}) }
        let!(:contest) { contest_creation.perform }

        before do
          pay_contest(contest)
        end

        it 'sets contest state to brief_pending' do
          expect(contest.status).to eq 'brief_pending'
          expect(contest.phase_end).to be_blank
        end

        it 'sends email about brief pending' do
          expect(jobs_with_handler_like('contest_not_live_yet').count).to eq 1
        end

        it 'stores information if the contest was in brief_pending state ever' do
          expect(contest.reload.was_in_brief_pending_state).to be_truthy
        end
      end
    end
  end

  context 'when contest expected to be incomplete' do
    let(:contest_creation) do
      ContestCreation.new(client_id: client.id,
                          contest_params: params,
                          make_complete: false)
    end

    context 'when space images set' do
      let(:params) { contest_options_source }
      let!(:contest) { contest_creation.perform }

      it 'does not make contest brief_pending' do
        expect(contest.status).to eq 'incomplete'
        expect(contest.phase_end).to be_blank
      end

      it 'does not send email about brief pending' do
        expect(jobs_with_handler_like('contest_not_live_yet').count).to eq 0
      end
    end

    context 'when space images empty' do
      let(:params) { contest_options_source.deep_merge({design_space: { document_id: nil }}) }
      let!(:contest) { contest_creation.perform }

      before do
        pay_contest(contest)
      end

      it 'does not make contest brief_pending' do
        expect(contest.status).to eq 'incomplete'
        expect(contest.phase_end).to be_blank
      end
    end
  end

end
