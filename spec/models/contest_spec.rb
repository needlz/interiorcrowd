require 'rails_helper'

RSpec.describe Contest do
  let(:client) { Fabricate(:client) }
  let(:contest) do
    Fabricate(:contest,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image),
              status: 'submission'
    )
  end

  it 'delays submission time by 7 days' do
    expect(contest.days_left).to eq 7
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
      submission_end_jobs = Delayed::Job.where('handler LIKE ?', "%#{ Jobs::SubmissionEnd.name }%")
      expect(submission_end_jobs.count).to eq 0
      contest.run_callbacks(:commit)
      expect(submission_end_jobs.count).to eq 1
      delayed_job = submission_end_jobs.first
      expect(delayed_job.contest_id).to eq contest.id
    end
  end

  describe 'winner_selection_end' do
    it 'closes the contest if there were no winners requests' do
      contest.end_winner_selection
      expect(contest.reload).to be_closed
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

  describe '#has_other_winners?' do
    let(:request){ Fabricate(:contest_request,
                             status: 'fulfillment',
                             designer_id: 2,
                             answer: 'winner',
                             contest_id: contest.id) }
    let(:submitted_request){ Fabricate(:contest_request,
                                       designer_id: 1,
                                       status: 'submitted',
                                       answer: 'maybe',
                                       contest_id: contest.id) }

    it 'has no other winners for contest' do
      expect(contest.has_other_winners?(request.id)).to eq(false)
    end

    it 'has another winner for contest' do
      request
      expect(contest.has_other_winners?(submitted_request.id)).to eq(true)
    end
  end

end
