class ClientContestCreationPolicy < Policy

  def self.for_client(client)
    new(client)
  end

  def initialize(client)
    super
    @client = client
  end

  def create_contest
    permissions << !client.contests.incomplete.exists?
    self
  end

  private

  attr_reader :client

end
