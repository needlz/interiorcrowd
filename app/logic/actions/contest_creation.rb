class ContestCreation

  attr_reader :contest

  def initialize(options)
    @promocode = options[:promocode]
    @client_id = options[:client_id]
    @params = options[:contest_params]
  end

  def on_success(&block)
    @after_created_callback = block
  end

  def perform
    raise ArgumentError unless ClientNextContestPolicy.new(Client.find(client_id)).can_create_next_contest?

    contest_options = ContestOptions.new(params.to_hash.merge(client_id: client_id))
    raise ArgumentError unless contest_options.required_present?
    @contest = Contest.new(contest_options.contest)
    @contest.transaction do
      @contest.save!
      apply_promocode(@contest)
      options_updater = ContestUpdater.new(@contest, contest_options)
      options_updater.update_options
      unless options_updater.contest_submission.performed?
        if options_updater.contest_submission.only_brief_pending?
          Jobs::Mailer.schedule(:contest_not_live_yet, [@contest])
        end
      end
    end
    after_created_callback.call(@contest) if after_created_callback.present?
    @contest
  end

  private

  attr_reader :client_id, :params, :after_created_callback, :promocode

  def apply_promocode(contest)
    code = Promocode.active.find_by_promocode(promocode)
    contest.promocodes << code if code
  end

end
