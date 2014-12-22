module Contests
  class SubmissionEndJob < Struct.new(:contest_id)
    def perform
      contest = Contest.find(contest_id)
      contest.end_submission
    end

    def queue_name
      Contest::JOBS_QUEUE
    end
  end
end
