class ContestPage

  def initialize(options)
    @contest = options[:contest]

    @view_context = options[:view_context]
    @contest_view = ContestView.new(contest_attributes: contest) if contest
    all_requests = contest.requests.ever_published.union(contest.requests.has_designer_comments).includes(:designer, :lookbook, :sound)
    @requests_present = all_requests.present?
    @comments_present = contest.notes.present?
    @answer = options[:answer]
    shown_requests = all_requests.by_answer(answer)
    @contest_requests = shown_requests.by_page(options[:page])
    @notes = contest.notes.by_client.order(created_at: :desc).includes(:client, :designer).map { |note| ContestNoteView.new(note, options[:current_user]) }
    @reviewer_feedbacks = contest.reviewer_feedbacks.includes(:invitation)
  end

  def requests_present?
    @requests_present
  end

  def comments_present?
    @comments_present
  end

  def invitable_designer_views
    return @invitable_designer_views if @invitable_designer_views
    invitable_designers = Designer.active.includes(portfolio: [:personal_picture]).all
    @invitable_designer_views = invitable_designers.map { |designer| DesignerView.new(designer) }
  end

  def show_mobile_pagination?
    requests_next_page_index
  end

  def requests_next_page_index
    contest_requests.current_page + 1 if contest_requests.current_page < contest_requests.total_pages
  end

  def timeline_hint
    nil
  end

  attr_reader :contest, :contest_view, :contest_requests, :notes, :reviewer_feedbacks,
              :answer, :view_context

end
