require "rails_helper"

RSpec.describe Contest do
  let(:client) { Fabricate(:client) }
  let(:contest) do
    Fabricate(:contest,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image)
    )
  end

  describe 'images association' do
    it 'updates liked examples' do
      old_examples = contest.liked_examples
      new_examples_ids = [old_examples[0].id, Fabricate(:image).id]
      params = { design_style: { document_id: new_examples_ids.join(',') } }
      options = ContestOptions.new(params)
      contest.update_from_options(options)
      expect(contest.reload.liked_examples.pluck(:id)).to eq new_examples_ids
    end
  end

  it 'delays submission time by 3 days' do
    expect(contest.days_left).to eq 3
  end

  it 'sets submission end time' do
    expect(contest.phase_end).to be_present
  end

  describe 'submission end' do
    it 'closes the contest if there were less than 3 requests' do
      contest.end_submission
      expect(contest.reload).to be_closed
    end

    it 'starts period of winner selection there were at least 3 requests' do
      3.times do
        contest.requests << Fabricate(:contest_request, designer: Fabricate(:designer))
      end
      contest.end_submission
      expect(contest.reload).to be_winner_selection
    end

    it 'performs delayed job' do
      Contests::SubmissionEndJob.new(contest.id).perform
      expect(contest.reload).to be_closed
    end
  end
end
