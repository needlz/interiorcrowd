class ContestRequestCreation

  def initialize(options)
    @designer = options[:designer]
    @contest = options[:contest]
    @request_params = options[:request_params]
    @lookbook_params = options[:lookbook_params]
    @need_submit = options[:need_submit]
  end

  def perform
    ContestRequest.transaction do
      create_request
      create_lookbook
      request.submit! if need_submit
      request
    end
  end

  private

  def create_request
    @request = ContestRequest.new(request_params)
    @request.assign_attributes(contest_id: contest.id, designer_id: designer.id)
    @request.save!
  end

  def create_lookbook
    AddLookbookItems.perform(request, lookbook_params, 'initial')
  end

  attr_reader :contest, :designer, :request, :request_params, :lookbook_params, :need_submit

end