require 'rails_helper'

RSpec.describe ContestCreation do

  let(:client) { Fabricate(:client) }

  def create_with_params
    contest_creation = ContestCreation.new(client_id: client.id, contest_params: params)
    contest_creation.perform
  end

  context 'space images set' do
    let(:params) { contest_options_source }
    let!(:contest) { create_with_params }

    it 'sets contest state to submission' do
      expect(contest.status).to eq 'submission'
      expect(contest.phase_end).to be_present
    end

    it 'does not send email about brief pending' do
      expect(jobs_with_handler_like('contest_not_live_yet').count).to eq 0
    end
  end

  context 'space images empty' do
    let(:params) { contest_options_source.deep_merge({design_space: { document_id: nil }}) }
    let!(:contest) { create_with_params }

    it 'sets contest state to brief_pending' do
      expect(contest.status).to eq 'brief_pending'
      expect(contest.phase_end).to be_blank
    end

    it 'sends email about brief pending' do
      expect(jobs_with_handler_like('contest_not_live_yet').count).to eq 1
    end
  end

end
