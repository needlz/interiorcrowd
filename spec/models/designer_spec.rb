require "rails_helper"

RSpec.describe Designer do
  let(:designer) { Fabricate(:designer) }
  let(:client) { Fabricate(:client) }
  let(:contest) { Fabricate(:contest, client: client) }

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
    let(:contest_with_requests) { Fabricate(:contest, client: client) }
    let(:request) { Fabricate(:contest_request, designer: designer, contest: contest_with_requests) }
    let(:concept_board_comment_of_client) { Fabricate(:concept_board_client_comment, user_id: client.id, contest_request: request) }
    let(:concept_board_comment_of_designer) { Fabricate(:concept_board_designer_comment, user_id: designer.id, contest_request: request) }

    let(:contest_comment_of_client) { contest.notes.create!(text: 'a note for designers', client_id: client.id) }
    let(:contest_comment_of_other_client) { Fabricate(:contest).notes.create!(text: 'a note from other client', client_id: client.id) }
    let(:contest_comment_of_designer) { contest.notes.create!(text: 'a note for client', designer_id: designer.id) }
    let(:contest_comment_from_other_designer) { contest.notes.create!(text: 'a note from other designer', designer_id: Fabricate(:designer).id) }
    let(:notification) { Fabricate(:designer_invite_notification, designer: designer, contest: contest) }

    it 'returns list of all related notifications' do
      concept_board_comment_of_client
      concept_board_comment_of_designer
      contest_comment_of_client
      contest_comment_of_other_client
      contest_comment_of_designer
      contest_comment_from_other_designer
      notification
      expect(designer.notifications).to match_array([concept_board_comment_of_client, contest_comment_of_client, notification])
    end

    it 'returns list of all related notifications' do
      contest_comment_of_client
      contest_comment_of_other_client
      contest_comment_of_designer
      contest_comment_from_other_designer
      notification
      expect(designer.notifications).to match_array([contest_comment_of_client, notification])
    end
  end

end
