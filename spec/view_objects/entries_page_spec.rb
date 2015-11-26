require 'rails_helper'

RSpec.describe EntriesPage do

  let(:client){ Fabricate(:client) }
  let(:contest){ Fabricate(:contest, client: client, status: 'submission', phase_end: Time.current) }
  let(:entries_page){ EntriesPage.new(
      contest: contest,
      view_context: RenderingHelper.new
  ) }

  context 'contest in winner_selection state' do
    before do
      contest.start_winner_selection!
    end

    it 'shows submissions list' do
      expect(entries_page.show_submissions?).to be_truthy
    end

    it 'returns timeline hint' do
      expect(entries_page.timeline_hint).to be_present
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

  describe '#current_user_owns_contest?' do
    context 'when logged in as contest owner' do
      let(:entries_page){ EntriesPage.new(
          contest: contest,
          current_user: client,
          view_context: RenderingHelper.new
      ) }

      it 'returns true' do
        expect(entries_page.current_user_owns_contest?).to be_truthy
      end
    end

    context 'when logged in as another client' do
      let(:entries_page){ EntriesPage.new(
          contest: contest,
          current_user: Fabricate(:client),
          view_context: RenderingHelper.new
      ) }

      it 'returns false' do
        expect(entries_page.current_user_owns_contest?).to be_falsey
      end
    end
  end

end
