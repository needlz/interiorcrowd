require 'rails_helper'

RSpec.describe EntriesPage do

  let(:client){ Fabricate(:client) }
  let(:contest){ Fabricate(:contest, client: client, status: 'submission') }
  let(:entries_page){ EntriesPage.new(
      contest: contest,
      view: nil,
      answer: nil,
      page: nil,
      current_user: nil,
      view_context: nil
  ) }

  context 'contest in winner_selection state' do
    before do
      contest.start_winner_selection!
    end

    it 'shows submissions list' do
      expect(entries_page.show_submissions?).to be_truthy
    end
  end

  context 'contest in submissions state' do
    context 'have no submissions and comments' do
      it 'does not show submissions list  status nd ' do
        expect(entries_page.show_submissions?).to be_falsey
      end
    end

    context 'have submissions' do
      let!(:contest_request){ Fabricate(:contest_request, contest: contest) }

      it 'shows submissions list' do
        expect(entries_page.show_submissions?).to be_truthy
      end
    end
  end

end
