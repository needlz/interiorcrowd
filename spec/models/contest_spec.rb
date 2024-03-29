require 'rails_helper'

RSpec.describe Contest do
  let(:client) { Fabricate(:client) }
  let(:contest) do
    Fabricate(:contest_in_submission,
              client: client,
              liked_examples: Fabricate.times(2, :example_image),
              space_images: Fabricate.times(2, :space_image)
    )
  end

  describe 'not paid scope' do
    it 'returns contests without client payments' do
      brief_pending_contest = Fabricate(:completed_contest, status: 'brief_pending')
      submission_contest = Fabricate(:contest_in_submission)
      paid_contest = Fabricate(:contest_in_submission)
      Fabricate(:client_payment, contest: paid_contest)
      expect(Contest.not_paid).to match_array([brief_pending_contest, submission_contest])
    end
  end

  it 'sets submission end time' do
    expect(contest.phase_end).to be_present
  end

  describe 'submission end' do
    it 'closes the contest if there were less than 3 requests' do
      EndSubmission.new(contest).perform
      expect(contest.reload).to be_closed
    end

    it 'starts period of winner selection there were at least 3 requests' do
      3.times do
        contest.requests << Fabricate(:contest_request, designer: Fabricate(:designer))
      end
      EndSubmission.new(contest).perform
      expect(contest.reload).to be_winner_selection
    end

    describe 'delayed job' do
      before do
        Jobs::ContestMilestoneEnd.new(contest.id, 'submission').perform
      end

      it 'changes status of the contest' do
        expect(contest.reload).to be_closed
      end
    end

    it 'creates delayed job on creation' do
      submission_end_jobs = jobs_with_handler_like(Jobs::ContestMilestoneEnd.name)
      expect(submission_end_jobs.count).to eq 0
      contest.run_callbacks(:commit)
      expect(submission_end_jobs.count).to eq 1
      delayed_job = submission_end_jobs.first
      expect(delayed_job.contest_id).to eq contest.id
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
                             status: 'fulfillment_ready',
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

  describe '#not_submitted_designers' do
    let!(:not_submitted_designer){ Fabricate(:designer) }
    let!(:inactive_designer){ Fabricate(:designer, active: false) }
    let!(:invited_only_designer) do
      designer = Fabricate(:designer)
      Fabricate(:designer_invite_notification, user_id: designer.id, contest: contest)
      designer
    end
    let!(:designer_draft) do
      designer = Fabricate(:designer)
      Fabricate(:contest_request, designer: designer, contest: contest, status: 'draft')
      designer
    end
    let!(:designer_submitted) do
      designer = Fabricate(:designer)
      Fabricate(:contest_request, designer: designer, contest: contest, status: 'submitted')
      designer
    end

    it 'returns designers who have not submitted a response' do
      expect(contest.not_submitted_designers).to match_array([not_submitted_designer, invited_only_designer])
    end
  end

  describe 'location_zip' do
    context 'when zip is nil' do
      let(:contest_without_location_zip) do
        Fabricate.build(:contest, location_zip: nil)
      end

      it 'is valid' do
        expect(contest_without_location_zip.valid?).to be_truthy
      end
    end

    context 'when setting Australian zip' do
      it 'is invalid' do
        contest.location_zip = '3585' #Murray Downs, VIC
        expect(contest.invalid?).to be_truthy
      end
    end

    context 'when setting Japan zip' do
      it 'is invalid' do
        contest.location_zip = '070-0035' #Asahikawa, Hokkaido
        expect(contest.invalid?).to be_truthy
      end
    end

    context 'when setting USA zip without space' do
      it 'is invalid' do
        contest.location_zip = '897044110' #Washoe Valley, Nevada
        expect(contest.invalid?).to be_truthy
      end
    end

    context 'when setting USA zip with space' do
      it 'is invalid' do
        contest.location_zip = '89704 4110' #Washoe Valley, Nevada
        expect(contest.invalid?).to be_truthy
      end
    end

    context 'when setting USA zip with hyphen' do
      it 'is valid' do
        contest.location_zip = '89704-4110' #Washoe Valley, Nevada
        expect(contest.valid?).to be_truthy
      end
    end

    context 'when setting USA state zip' do
      it 'is valid' do
        contest.location_zip = '89704' # Nevada
        expect(contest.valid?).to be_truthy
      end
    end
  end

  describe '#published?' do
    it 'returns true for all statuses after brief_pending in contests flow' do
      contest = Fabricate(:contest)
      Contest::STATUSES.each do |status|
        contest.update_column(:status, status)
        expect(contest.published?).to eq %w[incomplete brief_pending].exclude?(status)
      end
    end
  end

end
