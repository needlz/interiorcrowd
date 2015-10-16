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
    let(:concept_board_comment_of_client) { ConceptBoardCommentNotification.create!(user_id: designer.id) }

    let(:notification_for_designer) { ContestCommentDesignerNotification.create!(user_id: designer.id) }
    let(:notification_for_other_designer) { ContestCommentDesignerNotification.create!(user_id: Fabricate(:designer).id) }
    let(:invite_notification) { Fabricate(:designer_invite_notification, designer: designer, contest: contest) }

    it 'returns list of all related notifications' do
      concept_board_comment_of_client
      notification_for_designer
      notification_for_other_designer
      invite_notification
      expect(designer.notifications).to match_array([concept_board_comment_of_client,
                                                     notification_for_designer,
                                                     invite_notification])
    end

    it 'returns list of all related notifications' do
      notification_for_designer
      notification_for_other_designer
      invite_notification
      expect(designer.notifications).to match_array([notification_for_designer,
                                                     invite_notification])
    end
  end

  context 'can be active or inactive' do
    let(:active_designer) { Fabricate(:designer, active: true) }
    let(:inactive_designer) { Fabricate(:designer, active: false) }

    it 'returns only active designers when using corresponding scope' do
      inactive_designer
      active_designer
      expect(Designer.active.count).to eq(1)
      expect(Designer.active.first.active?).to be_truthy
    end
  end

  it 'capitalizes name' do
    designer.update_attributes!(first_name: 'wolfgang', last_name: 'von strucker')
    expect(designer.name).to eq('Wolfgang Von Strucker')
  end

  describe 'saving' do

    context 'when email has uppercase characters' do
      let(:email) { 'UPPER.email@example.com' }

      it 'saves email in lower case' do
        designer.update_attributes!(email: email)
        expect(designer.reload.email).to eq email.downcase
      end
    end

  end

end
