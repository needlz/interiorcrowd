require 'rails_helper'

RSpec.describe ContestCreation do

  let(:client) { Fabricate(:client_with_primary_card) }

  context 'when contest expected to be complete' do
    let(:contest_creation) do
      ContestCreation.new(client_id: client.id,
                          contest_params: params,
                          make_complete: true)
    end

    let(:contest) { contest_creation.perform }

    context 'when automatic payment enabled' do
      before do
        allow(Settings).to receive(:automatic_payment) { true }
      end

      context 'when space images set' do
        let(:params) { contest_options_source }

        context 'when contest paid' do
          before do
            pay_contest(contest)
          end

          it 'sets contest state to submission' do
            expect(contest.status).to eq 'submission'
            expect(contest.phase_end).to be_present
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_falsey
          end
        end

        context 'when contest not paid' do
          it 'sets contest state to submission' do
            expect(contest.status).to eq 'brief_pending'
            expect(contest.phase_end).to be_nil
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_falsey
          end
        end
      end

      context 'when space images empty' do
        let(:params) { contest_options_source.deep_merge({design_space: { document_id: nil }}) }

        context 'when contest paid' do
          before do
            pay_contest(contest)
          end

          it 'sets contest state to submission' do
            expect(contest.status).to eq 'brief_pending'
            expect(contest.phase_end).to be_nil
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_truthy
          end
        end

        context 'when contest not paid' do
          it 'sets contest state to submission' do
            expect(contest.status).to eq 'brief_pending'
            expect(contest.phase_end).to be_nil
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_falsey
          end
        end
      end
    end

    context 'when automatic payment disabled' do
      before do
        allow(Settings).to receive(:automatic_payment) { false }
      end

      context 'when space images set' do
        let(:params) { contest_options_source }

        context 'when contest paid' do
          before do
            pay_contest(contest)
          end

          it 'sets contest state to submission' do
            expect(contest.status).to eq 'submission'
            expect(contest.phase_end).to be_present
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_falsey
          end
        end

        context 'when contest not paid' do
          it 'sets contest state to submission' do
            expect(contest.status).to eq 'submission'
            expect(contest.phase_end).to be_present
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_falsey
          end
        end
      end

      context 'when space images empty' do
        let(:params) { contest_options_source.deep_merge({design_space: { document_id: nil }}) }

        context 'when contest paid' do
          before do
            pay_contest(contest)
          end

          it 'sets contest state to submission' do
            expect(contest.status).to eq 'brief_pending'
            expect(contest.phase_end).to be_nil
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_truthy
          end
        end

        context 'when contest not paid' do
          it 'sets contest state to submission' do
            expect(contest.status).to eq 'brief_pending'
            expect(contest.phase_end).to be_nil
          end

          it 'stores information if the contest was in brief_pending state ever' do
            expect(contest.reload.was_in_brief_pending_state).to be_falsey
          end
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
