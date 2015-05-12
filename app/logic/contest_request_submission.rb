class ContestRequestSubmission

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    contest_request.submit!
    Jobs::Mailer.schedule(:concept_board_received, [contest_request])
    BoardSubmittedDesignerNotification.create!(user_id: contest_request.designer.id,
                                               contest_request_id: contest_request.id,
                                               contest_id: contest_request.contest.id)
  end

  private

  attr_reader :contest_request

end
