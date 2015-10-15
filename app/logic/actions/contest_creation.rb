class ContestCreation

  attr_reader :contest

  def initialize(options)
    @promocode = options[:promocode]
    @client_id = options[:client_id]
    @params = options[:contest_params]
    @make_complete = options[:make_complete]
  end

  def on_success(&block)
    @after_created_callback = block
  end

  def perform
    contest_options = ContestOptions.new(params.to_hash.merge(client_id: client_id))
    raise ArgumentError.new('previous contest not finished') if @make_complete && !ClientNextContestPolicy.new(Client.find(client_id)).can_complete_next_contest?
    raise ArgumentError.new('contest incomplete') if validate_completion? && !contest_options.required_present?
    @contest = Contest.new(contest_options.contest)
    @contest.transaction do
      @contest.save!
      if @make_complete
        contest_completion = CompleteContest.new(@contest)
        contest_completion.perform
      end
      apply_promocode(@contest)
      options_updater = ContestUpdater.new(@contest, contest_options)
      options_updater.update_options
    end
    after_created_callback.call(@contest) if after_created_callback.present?
    @contest
  end

  private

  attr_reader :client_id, :params, :after_created_callback, :promocode

  def apply_promocode(contest)
    ApplyPromocode.new(contest, promocode).perform
  end

  def validate_completion?
    @make_complete
  end

end
