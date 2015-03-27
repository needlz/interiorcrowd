class ContestResponseShowPage < ContestResponsePage

  def initialize(options)
    @contest_request = options[:contest_request]
    @preferred_view = options[:preferred_view].to_i if options[:preferred_view]
    @contest_request_view = options[:contest_request_view]
    @view_context = options[:view_context]
  end

 def step_url(index)
    path_params = { id: contest_request.id }
    path_params.merge!(view: index)
    view_context.designer_center_response_path(path_params)
  end

  def selected_step
    @preferred_view
  end

  def image_items_partial
    return partial_by_preferred_view(preferred_view) if preferred_view
    default_image_items_partial
  end

  private

  attr_reader :contest_request, :preferred_view, :contest_request_view, :view_context

  def partial_by_preferred_view(view)
    send(STEPS_TO_PARTIALS[view])
  end

  def default_image_items_partial
    partial_by_preferred_view(PhasesStripe::STATUSES_TO_PHASES[contest_request.status])
  end

  def initial; end

  def product_list
    { partial: 'designer_center_requests/show/image_items_creation_phase' }
  end

  def final_design
    { partial: 'designer_center_requests/show/image_items_final_phase' }
  end

end
