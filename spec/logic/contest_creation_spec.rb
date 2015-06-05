require 'rails_helper'

RSpec.describe ContestCreation do

  let(:client) { Fabricate(:client) }

  def create_with_params
    contest_creation = ContestCreation.new(client.id, params)
    contest_creation.perform
  end

  context 'space images set' do
    let(:params) { contest_options_source }
    let(:contest) { create_with_params }

    it 'sets contest state to submission' do
      expect(contest.status).to eq 'submission'
      expect(contest.phase_end).to be_present
    end
  end

  context 'space images empty' do
    let(:params) { contest_options_source.deep_merge({design_space: { document_id: nil }}) }
    let(:contest) { create_with_params }

    it 'sets contest state to brieef_pending' do
      expect(contest.status).to eq 'brief_pending'
      expect(contest.phase_end).to be_blank
    end
  end



end
