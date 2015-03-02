class ContestRequestCreation

  def initialize(options)
    @designer = options[:designer]
    @contest = options[:contest]
    @request_params = options[:request_params]
    @lookbook_params = options[:lookbook_params]
    @need_submit = options[:need_submit]
    @comment = options[:comment]
  end

  def perform
    ContestRequest.transaction do
      create_request
      create_lookbook
      create_comment
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
    request.update_attributes(lookbook_id: Lookbook.create!.id)

    if lookbook_params.try(:[], :picture).try(:[], :ids).present?
      document_ids = lookbook_params[:picture][:ids]
      document_ids.each do |doc|
        LookbookDetail.create!({lookbook_id: request.lookbook.id,
                                image_id: doc,
                                doc_type: LookbookDetail::UPLOADED_PICTURE_TYPE })
      end
    end
  end

  def create_comment
    return if comment.blank?
    request.comments.create(text: comment, read: false, role: 'Designer', user_id: designer.id)
  end

  attr_reader :contest, :designer, :request, :request_params, :lookbook_params, :need_submit, :comment

end