class ContestRequestSubmission

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    ActiveRecord::Base.transaction do
      contest_request.submit!
      contest_request.update_attributes(submitted_at: Time.now)
      Jobs::Mailer.schedule(:concept_board_received, [contest_request])
      BoardSubmittedDesignerNotification.create!(user_id: contest_request.designer.id,
                                                 contest_request_id: contest_request.id,
                                                 contest_id: contest_request.contest.id)
    end
  end

  private

  attr_reader :contest_request

end
