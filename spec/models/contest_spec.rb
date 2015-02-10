require 'rails_helper'

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
      expect(contest.reload.liked_examples.pluck(:id)).to match_array new_examples_ids
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

    describe 'delayed job' do
      before do
        Jobs::SubmissionEnd.new(contest.id).perform
      end

      it 'changes status of the contest' do
        expect(contest.reload).to be_closed
      end
    end

    it 'creates delayed job on creation' do
      expect(Delayed::Job.where('handler LIKE ?', "%#{ Jobs::SubmissionEnd.name }%").count).to eq 0
      contest.run_callbacks(:commit)
      expect(Delayed::Job.where('handler LIKE ?', "%#{ Jobs::SubmissionEnd.name }%").count).to eq 1
    end
  end

  describe '#close_requests' do
    it 'closes requests' do
      draft = Fabricate(:contest_request, contest: contest, designer: Fabricate(:designer), status: 'draft')
      submitted = Fabricate(:contest_request, contest: contest, designer: Fabricate(:designer), status: 'submitted')
      contest.close_requests
      statuses = [draft, submitted].map { |request| request.reload.status }
      expect(statuses.uniq).to eq ['closed']
    end
  end

  describe 'additional preferences validation' do
    it 'allows to set only allowed values' do
      ContestAdditionalPreference::PREFERENCES.each do |preference, options|
        options.each do |option|
          contest.update_attributes(preference => option.to_s)
          expect(contest.reload.send(preference)).to eq option.to_s
        end
      end
    end

    it 'does not allow to set unknown preferences' do
      ContestAdditionalPreference.preferences.each do |preference|
        contest.update_attributes(preference => 'unknown')
        expect(contest.reload.send(preference)).to_not eq 'unknown'
      end
    end
  end

  describe '#responses_answerable?' do
    it 'returns true if contest is in submission or winner_selection state' do
      %w(submission winner_selection).each do |status|
        contest.update_attributes!(status: status)
        expect(contest.responses_answerable?).to be_truthy
      end
    end

    it 'returns false if contest is not in submission or winner_selection state' do
      (Contest::STATUSES - %w(submission winner_selection)).each do |status|
        contest.update_attributes!(status: status)
        expect(contest.responses_answerable?).to be_falsey
      end
    end
  end

  describe 'designers' do
    it 'can be invited if contest has the submission state' do
      expect(contest.designers_invitation_period?).to be_truthy
    end

    it 'can not be invited if contest has not the submission state' do
      contest.start_winner_selection!
      expect(contest.designers_invitation_period?).to be_falsey
    end
  end
end
