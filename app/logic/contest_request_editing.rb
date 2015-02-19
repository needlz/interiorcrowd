class ContestRequestEditing

  def initialize(options)
    @request = options[:request]
    @contest_request_params = options[:contest_request]
  end

  def perform
    update_image
    update_text
    update_status
    update_image_items
  end

  private

  def update_image
    if contest_request_params[:image_id]
      lookbook_id = request.lookbook.id
      details = LookbookDetail.find_by_lookbook_id(lookbook_id)
      details.update(image_id: contest_request_params[:image_id])
    end
  end

  def update_text
    if contest_request_params[:feedback]
      request.update(feedback: contest_request_params[:feedback])
    end
  end

  def update_status
    return request.submit! if contest_request_params[:status] == 'submitted'
    request.ready_fulfillment! if contest_request_params[:status] == 'fulfillment_ready' && request.fulfillment?
  end

  def update_image_items
    ImageItemsEditing.new(request, contest_request_params).perform
  end

  attr_reader :request, :contest_request_params

end