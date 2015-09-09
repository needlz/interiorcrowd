class ClientNextContestPolicy

  def initialize(client)
    @client = client
  end

  def can_create_next_contest?
    return true unless client.last_contest
    Contest::FINISHED_STATUSES.include? client.last_contest.status
  end

  private

  attr_reader :client
end
