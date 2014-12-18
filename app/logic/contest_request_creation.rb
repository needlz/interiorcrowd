class ContestRequestCreation

  def initialize(options)
    @designer = options[:designer]
    @contest = options[:contest]
    @request_params = options[:request_params]
    @lookbook_params = options[:lookbook_params]
    @submit = options[:submit]
  end

  def perform
    ContestRequest.transaction do
      create_request
      create_lookbook
      request.submit! if submit
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
    request.lookbook = Lookbook.create!

    if lookbook_params.try(:[], :picture).try(:[], :ids).present?
      document_ids = lookbook_params[:picture][:ids]
      document_ids.each do |doc|
        LookbookDetail.create!({lookbook_id: request.lookbook.id,
                                image_id: doc,
                                doc_type: LookbookDetail::UPLOADED_PICTURE_TYPE })
      end
    end
  end

  attr_reader :contest, :designer, :request, :request_params, :lookbook_params, :submit

end