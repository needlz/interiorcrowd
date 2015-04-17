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

  attr_reader :request, :contest_request_params, :contest_request_attributes

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
    return perform_submission if contest_request_params[:status] == 'submitted'
    request.ready_fulfillment! if contest_request_params[:status] == 'fulfillment_ready' && request.fulfillment?
    perform_finish if contest_request_params[:status] == 'finished' && request.fulfillment_approved?
  end

  def update_image_items
    request_phase = ContestPhases.status_to_phase(request.status)
    new_item_attributes = {final: true} if finalize_image_items?(request_phase)
    items_editing = ImageItemsEditing.new(
      contest_request_options: contest_request_params,
      items_scope: request.visible_image_items(request_phase),
      new_items_attributes: new_item_attributes
    )
    NewProductListItemNotifier.new(request).perform if items_editing.has_new_product_items
    items_editing.perform
  end

  def finalize_image_items?(request_phase)
    request_phase == :final_design
  end

  def perform_submission
    submission = ContestRequestSubmission.new(request)
    submission.perform
  end

  def perform_finish
    request.finish!
    request.contest.finish!
  end

  def are_there_new_product_items?
    contest_request_params['product_items']['ids'].detect(&:blank?) == ''
  end

end
