require 'rails_helper'

RSpec.describe CreateFinalNote do

  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, status: 'submission', client: client) }
  let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest) }
  let(:text) { 'final note' }

  it 'creates notification to designer' do
    creation = CreateFinalNote.new(contest_request: contest_request,
                                   author: client,
                                   final_note_attributes: { text: text } )
    creation.perform
    final_note = FinalNote.first
    expect(final_note.text).to eq text
  end

end
