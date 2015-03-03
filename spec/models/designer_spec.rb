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

  it 'returns related comments' do
    contest.notes.create!(text: 'a note for designers')
    Fabricate(:concept_board_client_comment, user_id: client.id, contest_request: request)

    expect(designer.related_comments.length).to eq 2
  end

end
