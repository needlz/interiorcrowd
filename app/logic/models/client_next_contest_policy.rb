class ClientNextContestPolicy

  def initialize(client)
    @client = client
  end

  def can_complete_next_contest?
    return true unless client.contests.exists?
    !client.contests.where(status: Contest::COMPLETED_NON_FINISHED_STATUSES).exists?
  end

  private

  attr_reader :client

end
