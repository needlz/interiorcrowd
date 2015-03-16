require "rails_helper"

RSpec.describe Designer do
  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }
  let(:request) { Fabricate(:contest_request, designer: designer, contest: contest) }

  describe '#create_portfolio' do
    let(:images) { [Fabricate(:image), Fabricate(:image)] }
    let(:links) { ['link1', 'link2'] }
    let(:portfolio_params) do
      {
        picture_ids: images.map(&:id).join(','),
        example_links: links
      }
    end

    it 'creates portfolio' do
      designer.create_portfolio(portfolio_params)
      expect(designer.portfolio).to be_present
    end

    it 'automatically generates portfolio path' do
      designer.create_portfolio(portfolio_params)
      expect(designer.portfolio.reload.path).to be_present
    end

    it 'creates portfolio if only one of parameter is present' do
      portfolio_params.each do |key, value|
        designer.create_portfolio({ key => value })
        expect(designer.reload.portfolio).to be_present
        designer.portfolio.destroy
      end
    end
  end

  context 'has comments and notifications' do
    let!(:concept_board_comment) { Fabricate(:concept_board_client_comment, user_id: client.id, contest_request: request) }
    let!(:contest_comment) { contest.notes.create!(text: 'a note for designers', client_id: client.id) }
    let!(:contest_comment_form_other_designer) { contest.notes.create!(text: 'a note from other designer', designer_id: Fabricate(:designer).id) }
    let!(:notification) { Fabricate(:designer_invite_notification, designer: designer, contest: contest) }

    it 'returns related comments' do
      expect(designer.related_comments.length).to eq 2
    end

    it 'returns list of all related notifications' do
      expect(designer.notifications).to match_array([concept_board_comment, contest_comment, notification])
    end
  end

end
