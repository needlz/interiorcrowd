class ContestRequestEditing

  def initialize(options)
    @request = options[:request]
    @contest_request_params = options[:contest_request_options]
    @contest_request_attributes = options[:contest_request_attributes]
  end

  def perform
    update_attributes
    if contest_request_params
      update_image
      update_status
    end
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

  def update_attributes
    if contest_request_attributes.present?
      request.update_attributes!(contest_request_attributes)
    end
  end

  def update_status
    return request.submit! if contest_request_params[:status] == 'submitted'
    request.ready_fulfillment! if contest_request_params[:status] == 'fulfillment_ready' && request.fulfillment?
    request.finish! if contest_request_params[:status] == 'finished' && request.fulfillment_approved?
  end

  def update_image_items
    ImageItemsEditing.new(request, contest_request_params).perform
  end

  attr_reader :request, :contest_request_params, :contest_request_attributes

end
