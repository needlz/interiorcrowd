class ConceptBoardPage::Base < PhasesHolder

  include ActionView::Helpers::TranslationHelper

  attr_reader :contest_request

  IMAGE_ITEMS_PER_PAGE = 10

  def initialize(options)
    @contest_page = options[:contest_page]
    @contest_request = options[:contest_request]
    @preferred_view_index = options[:preferred_view].to_i if options[:preferred_view]
    @contest_request_view = options[:contest_request_view]
    @view_context = options[:view_context]
    @pagination_options = options[:pagination_options]
    super()
  end

  def selected_step
    @preferred_view_index
  end

  def image_items
    contest_request.image_items.of_phase(phases_stripe.active_phase).for_view
  end

  def product_items
    contest_request.image_items.product_items.of_phase(phases_stripe.active_phase).for_view
  end

  def similar_styles
    contest_request.image_items.similar_styles.of_phase(phases_stripe.active_phase).for_view
  end

  def current_lookbook_items
    contest_request.lookbook_items_by_phase(phases_stripe.active_phase)
  end

  def concept_board_images
    contest_request.lookbook_items_by_phase(phases_stripe.active_phase).map(&:image)
  end

  def editable?
    contest_request.editable? && (phases_stripe.active_step >= phases_stripe.last_phase_index)
  end

  def contest_name
    contest_request.contest.name
  end

  def designer_name
    contest_request.designer.name
  end

  def request_comments
    @request_comments ||= contest_request.comments.map { |comment| ConceptBoardCommentView.new(comment, contest_request.designer) }
  end

  def final_notes
    @final_notes ||= FinalNotesQuery.new(contest_request).all.map { |comment| ConceptBoardCommentView.new(comment, contest_request.designer) }
  end

  def image_items_partial
    raise NotImplementedError
  end

  def previous_step?
    return @contest_page.phases_stripe.previous_step? if @contest_page
    phases_stripe.previous_step?
  end

  protected

  def create_phases_stripe
    PhasesStripe.new(selected_step: @preferred_view_index,
                     last_step: ContestPhases.status_to_index(@contest_request.status),
                     view_context: @view_context,
                     contest_request_status: @contest_request.status,
                     step_url_renderer: self)
  end

  private

  attr_reader :preferred_view_index, :contest_request_view, :view_context

  def phase_dependent_partial
    send(phases_stripe.active_phase)
  end

  def phase_url_params(index)
    path_params = { id: contest_request.id }
    path_params.merge!(view: index) if index != phases_stripe.last_phase_index
    path_params
  end

end
