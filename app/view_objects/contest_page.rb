class ContestPage

  attr_reader :contest, :contest_view, :contest_requests, :notes, :reviewer_feedbacks,
              :answer, :view_context

  def initialize(options)
    @contest = options[:contest]

    @view_context = options[:view_context]
    @contest_view = ContestView.new(contest_attributes: contest) if contest
    all_requests = contest.requests.client_sees_in_entries.includes(:designer, :lookbook, :sound)
    @requests_present = all_requests.present?
    @answer = options[:answer]
    shown_requests = all_requests.by_answer(answer)
    @contest_requests = shown_requests.by_page(options[:page])
    @notes = contest.notes.by_client.order(created_at: :desc).includes(:client, :designer).map { |note| ContestNoteView.new(note, options[:current_user]) }
    @reviewer_feedbacks = contest.reviewer_feedbacks.includes(:invitation)
    @current_user = options[:current_user]
  end

  def requests_present?
    @requests_present
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

  def show_invite_designers_link?
    ContestPolicies.new(contest).invite_designers_page_accessible?
  end

  private

  attr_reader :current_user

end
