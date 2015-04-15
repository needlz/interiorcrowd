class ContestRequestSubmission

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    contest_request.submit!
    Jobs::Mailer.schedule(:concept_board_received, [contest_request, Settings.app_host])
  end

  private

  attr_reader :contest_request

end
