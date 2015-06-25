class EntriesPage < ContestPage

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
      @visible_image_items = entries_concept_board_page.image_items.paginate(per_page: 4, page: options[:page])
      @share_url = view_context.public_designs_url(token: won_contest_request.token)
    end
  end

  def show_submissions?
    @show_submissions
  end

  def show_answer_options?
    contest.winner_selection? || contest.submission?
  end

  def timeline_hint
    if contest.submission?
      I18n.t('client_center.entries.submission.day_left_to_submit',
        time_left: view_context.distance_of_time_in_words(Time.current,
                                             contest.phase_end,
                                             false,
                                             highest_measure_only: true))
    elsif contest.winner_selection?
      select_winner_hint
    end
  end

  attr_reader :won_contest_request, :entries_concept_board_page, :visible_image_items, :share_url

  private

  def select_winner_hint
    if contest.phase_end < Time.current
      I18n.t('client_center.entries.winner_selection.hint')
    else
      I18n.t('client_center.entries.winner_selection.day_left',
             time_left: view_context.distance_of_time_in_words(Time.current,
                                                               contest.phase_end,
                                                               false,
                                                               highest_measure_only: true))
    end
  end

end
