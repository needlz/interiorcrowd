class ContestRequestEditing

  def initialize(options)
    @request = options[:request]
    @contest_request_params = options[:contest_request_options]
    @contest_request_attributes = options[:contest_request_attributes]
    @event_tracker = options[:event_tracker]
    @image_items_updater = ImageItemsDefaultUpdater
  end

  def perform
    update_attributes
    if contest_request_params
      update_image
      update_status
    end
    update_image_items
  end

  def submitted?
    @submitted
  end

  private

  attr_reader :request, :contest_request_params, :contest_request_attributes, :event_tracker,
              :image_items_updater

  def update_image
    if contest_request_params[:image_id]
      details = request.current_lookbook_item
      details.update(image_id: contest_request_params[:image_id])
    end
  end

  def update_attributes
    if contest_request_attributes.present?
      request.update_attributes!(contest_request_attributes)
    end
  end

  def update_status
    PhaseUpdater.new(request).perform_phase_change do
      return perform_submission if contest_request_params[:status] == 'submitted'
      perform_ready_fulfillment if contest_request_params[:status] == 'fulfillment_ready' && request.fulfillment?
      perform_finish if contest_request_params[:status] == 'finished' && request.fulfillment_approved?
    end
  end

  def update_image_items
    phase = ContestPhases.status_to_phase(request.status)
    new_item_attributes = { final: true } if finalize_image_items?(phase)
    items_editing = ImageItemsEditing.new(
      contest_request_options: contest_request_params,
      items_scope: request.visible_image_items(phase),
      new_items_attributes: new_item_attributes,
      image_items_updater: image_items_updater
    )
    items_editing.perform
    NewProductListItemNotifier.new(request).perform if items_editing.has_new_product_items
  end

  def finalize_image_items?(request_phase)
    request_phase == :final_design
  end

  def perform_submission
    submission = ContestRequestSubmission.new(request)
    submission.perform
    event_tracker.contest_request_submitted(request)
    @submitted = true
  end

  def perform_finish
    request.finish!
    request.contest.finish!
    event_tracker.final_design_submitted(request)
  end

  def perform_ready_fulfillment
    request.ready_fulfillment!
    destroy_empty_image_items
  end

  def destroy_empty_image_items
    request.image_items.where(image_id: nil).destroy_all
  end

end
