require 'rails_helper'

RSpec.describe FinalNote do

  let(:client) { Fabricate(:client) }
  let(:designer) { Fabricate(:designer) }
  let(:contest) { Fabricate(:contest_in_submission, client: client) }
  let(:contest_request) { Fabricate(:contest_request, contest: contest, designer: designer, status: 'submitted') }
  let(:final_note_by_client) { Fabricate(:final_note,
                                         author_id: client.id,
                                         author_role: client.role,
                                         contest_request: contest_request) }
  let(:final_note_by_designer) { Fabricate(:final_note,
                                         author_id: designer.id,
                                         author_role: designer.role,
                                         contest_request: contest_request) }

  describe 'validations' do
    it 'allows correct attributes' do
      expect do
        final_note_by_client.update_attributes!(author_role: designer.role,
                                                author_id: designer.id,
                                                contest_request_id: Fabricate(:contest_request).id)
      end.to_not raise_error
    end

    it 'require contest_request_id' do
      expect do
        final_note_by_client.update_attributes!(contest_request_id: nil)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'require author_id' do
      expect do
        final_note_by_client.update_attributes!(author_id: nil)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'require author_role' do
      expect do
        final_note_by_client.update_attributes!(author_role: 'unknown')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires text' do
      expect do
        final_note_by_client.update_attributes!(text: '  ')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#author' do
    it 'returns author' do
      expect(final_note_by_client.author).to eq client
      expect(final_note_by_designer.author).to eq designer
    end
  end

end
