class ContestResponseEditingPage < ContestResponsePage

  def initialize(options)
    @contest_request = options[:contest_request]
    @preferred_view = options[:preferred_view].to_i if options[:preferred_view]
    @contest_request_view = options[:contest_request_view]
    @view_context = options[:view_context]
  end

  def view_partial
    if preferred_view
      partial_by_preferred_view(preferred_view)
    else
      default
    end
  end

  def selected_step
    @preferred_view
  end

  def step_url(index)
    path_params = { id: contest_request.id }
    path_params.merge!(view: index)
    view_context.edit_designer_center_response_path(path_params)
  end

  private

  attr_reader :contest_request, :preferred_view, :contest_request_view, :view_context

  def partial_by_preferred_view(preferred_view)
    send(STEPS_TO_PARTIALS[preferred_view])
  end

  def default
    partial_by_preferred_view(PhasesStripe::STATUSES_TO_PHASES[contest_request.status])
  end

  def initial
    { partial: 'designer_center_requests/edit/concept_board_editing_layout',
      locals: { request: contest_request }
    }
  end

  def product_list
    { partial: 'designer_center_requests/edit/image_items_editing_layout',
      locals: { request: contest_request }
    }
  end

  def final_design
    { partial: 'designer_center_requests/edit/final_upload',
      locals: { contest_request: contest_request,
                image_items: contest_request_view.image_items }
    }
  end

end
