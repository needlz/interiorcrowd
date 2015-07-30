class ClientNextContestPolicy

  def initialize(client)
    @client = client
  end

  def can_create_next_contest?
    if client.last_contest
      Contest::FINISHED_STATUSES.include? client.last_contest.try(:status)
    else
      true
    end
  end

  private

  attr_reader :client
end
