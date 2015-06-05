class ContestCreation

  def initialize(client_id, params, &after_created)
    @client_id = client_id
    @params = params
    @after_created_callback = after_created
  end

  def perform
    contest_options = ContestOptions.new(params.to_hash.merge(client_id: client_id))
    raise ArgumentError unless contest_options.required_present?
    contest = Contest.create_from_options(contest_options)
    after_created_callback.call(contest) if after_created_callback.present?
    contest
  end

  private

  attr_reader :client_id, :params, :after_created_callback

end
