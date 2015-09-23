class EntriesPage < ContestPage

  attr_reader :won_contest_request, :entries_concept_board_page, :visible_image_items, :share_url

  def initialize(options)
    super

    @won_contest_request = contest.response_winner
    @show_submissions = (contest.submission? && (requests_present? || comments_present?)) || contest.winner_selection?

    if won_contest_request
      @entries_concept_board_page = EntriesConceptBoard.new({
        contest_request: @won_contest_request,
        view_context: view_context,
        preferred_view: options[:view]
      })
      @visible_image_items = entries_concept_board_page.image_items.paginate(per_page: 10, page: options[:page])
      @share_url = view_context.public_designs_url(token: won_contest_request.token)
    end
  end

  def show_submissions?
    @show_submissions
  end

  def show_winner_chosen_congratulations?
    won_contest_request && won_contest_request.image_items.published.blank?
  end

  def show_answer_options?
    contest.winner_selection? || contest.submission?
  end

  def timeline_hint
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
    result = []
    if won_contest_request && entries_concept_board_page.actual_phase_view?
      result << ['shared/finalize_design_confirmation'] if won_contest_request.fulfillment_ready?
      result << ['clients/client_center/entries/popups/wait_for_final_design',
                 contest: contest,
                 time_left: time_till_milestone_end] if won_contest_request.fulfillment_approved?
    end
    result
  end

  def breadcrumbs
    return @breadcrumbs if @breadcrumbs
    @breadcrumbs = Breadcrumbs::Client.new(view_context)
    if show_particular_request?
      @breadcrumbs.my_contests.contest(contest, true).contest_request(won_contest_request)
    else
      @breadcrumbs.my_contests.contest(contest)
    end
    @breadcrumbs
  end

  def show_particular_request?
    won_contest_request && entries_concept_board_page.active_step != ContestPhases.phase_to_index(:initial)
  end

  private

  def time_till_milestone_end
    DurationHumanizer.to_string(view_context, Time.current, contest.phase_end)
  end

end
