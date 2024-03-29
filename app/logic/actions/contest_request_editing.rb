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
      details = request.current_lookbook_items
      details.update(image_id: contest_request_params[:image_id])
    end
  end

  def update_attributes
    if contest_request_attributes.present?
      request.update_attributes!(contest_request_attributes)
    end
  end

  def update_status
    PhaseUpdater.new(request).monitor_phase_change do
      return perform_submission if contest_request_params[:status] == 'submitted'
      perform_finish if contest_request_params[:status] == 'finished' && request.fulfillment_approved?
    end
  end

  def update_image_items
    phase = ContestPhases.status_to_phase(request.status)
    items_editing = ImageItemsEditing.new(
      contest_request_options: contest_request_params,
      items_scope: request.image_items.of_phase(phase),
      new_items_attributes: new_image_item_attributes(phase),
      image_items_updater: image_items_updater
    )
    items_editing.perform
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
    finish_contest_request = FinishContestRequest.new(request)
    finish_contest_request.perform
    event_tracker.final_design_submitted(request)
  end

  def new_image_item_attributes(phase)
    { final: true, status: 'published' } if finalize_image_items?(phase)
  end

end
