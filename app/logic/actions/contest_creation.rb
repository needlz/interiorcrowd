class ContestCreation

  def initialize(client_id, params)
    @client_id = client_id
    @params = params
  end

  def on_success(&block)
    @after_created_callback = block
  end

  def perform
    contest_options = ContestOptions.new(params.to_hash.merge(client_id: client_id))
    raise ArgumentError unless contest_options.required_present?
    contest = Contest.new(contest_options.contest)
    contest.transaction do
      contest.save!
      options_updater = ContestUpdater.new(contest, contest_options)
      options_updater.update_options
      unless options_updater.contest_submission.performed?
        if options_updater.contest_submission.only_brief_pending?
          Jobs::Mailer.schedule(:contest_not_live_yet, [contest])
        end
      end
    end
    after_created_callback.call(contest) if after_created_callback.present?
    contest
  end

  private

  attr_reader :client_id, :params, :after_created_callback

end
