class EntriesPage < ContestPage

  attr_reader :won_contest_request, :entries_concept_board_page, :visible_image_items, :share_url, :phases_stripe

  def initialize(options)
    super

    @won_contest_request = contest.response_winner
    @show_submissions = (contest.submission? && requests_present?) || contest.winner_selection?

    if won_contest_request
      page_class = "ConceptBoardPage::ClientPerspective::#{ won_contest_request.status.camelize }".constantize

      @entries_concept_board_page = page_class.new({
        contest_request: @won_contest_request,
        view_context: view_context,
        preferred_view: @selected_view,
        contest_page: self,
        pagination_options: options[:pagination_options]
      })
      @visible_image_items = entries_concept_board_page.image_items.paginate(per_page: 10, page: options[:image_items_page])
      @share_url = view_context.public_designs_url(token: won_contest_request.token)
      @phases_stripe = entries_concept_board_page.phases_stripe
    else
      @phases_stripe = PhasesStripe.new(last_step: 0)
    end
  end

  def show_submissions?
    @show_submissions
  end

  def show_winner_chosen_congratulations?
    won_contest_request && won_contest_request.image_items.published.blank?
  end

  def timeline_hint
    return if entries_concept_board_page.try(:previous_step?)
    if ContestMilestone.finite_milestone?(contest.status)
      if contest.phase_end < Time.current
        I18n.t("client_center.entries.timelines.#{ contest.status }.expired")
      else
        I18n.t("client_center.entries.timelines.#{ contest.status }.time_left",
               time_left: time_till_milestone_end)
      end
    end
  end

  def javascripts
    result = []
    if won_contest_request
      if won_contest_request.fulfillment_editing?
        result << 'clients/product_list_marks'
      end
      if won_contest_request.fulfillment_ready?
        result << 'shared/final_design_dialog'
      end
    end
    result
  end

  def container_css_class
    'bottom60 entries-page' if contest.submission? || contest.winner_selection?
  end

  def onload_popups
    return [] if entries_concept_board_page.try(:previous_step?)
    result = []
    if won_contest_request
      result << ['shared/finalize_design_confirmation'] if won_contest_request.fulfillment_ready?
      result << ['clients/client_center/entries/popups/wait_for_final_design',
                 contest: contest,
                 time_left: time_till_milestone_end] if won_contest_request.fulfillment_approved?
    end
    result
  end

  def current_user_owns_contest?
    contest.client == current_user
  end

  def partial
    if won_contest_request && !(entries_concept_board_page.active_phase == :initial)
      { partial: 'clients/client_center/entries/entry', locals: { entries_page: self } }
    else
      { partial: 'clients/client_center/entries/entries', locals: { entries_page: self } }
    end
  end

  private

  def time_till_milestone_end
    DurationHumanizer.to_string(view_context, Time.current, contest.phase_end)
  end

end
