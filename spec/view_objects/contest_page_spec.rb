require 'rails_helper'

RSpec.describe ContestPage do
  let(:client){ Fabricate(:client) }
  let(:designer){ Fabricate(:designer) }
  let(:contest){ Fabricate(:contest, client: client, status: 'submission', phase_end: Time.current) }
  let(:client_note){ ContestNote.create(client: client, contest: contest, text: 'test') }
  let(:designer_note){ ContestNote.create(designer: designer, contest: contest, text: 'test') }
  let(:contest_page){ ContestPage.new(
      contest: contest,
      view: nil,
      answer: nil,
      page: nil,
      current_user: nil,
      view_context: RenderingHelper.new
  ) }

  it 'returns only client\'s notes' do
    client_note
    designer_note
    expect(contest_page.notes.count).to eq(1)
  end

end
