require 'rails_helper'

RSpec.describe CreateFinalNoteToDesigner do

  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest) { Fabricate(:contest, status: 'submission', client: client) }
  let(:contest_request) { Fabricate(:contest_request, designer: designer, contest: contest) }
  let(:text) { 'final note' }

  it 'creates notification to designer' do
    creation = CreateFinalNoteToDesigner.new(contest_request: contest_request,
                                             client: client,
                                             final_note_attributes: { text: text } )
    creation.perform
    final_note = FinalNoteToDesigner.first
    expect(final_note.text).to eq text
    expect(final_note.designer_notification.contest_request).to eq contest_request
  end

end
