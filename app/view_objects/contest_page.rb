class ContestPage

  def initialize(options)
    @contest = options[:contest]

    @view_context = options[:view_context]
    @contest_view = ContestView.new(contest_attributes: contest)
    all_requests = contest.requests.ever_published.includes(:designer, :lookbook, :sound)
    @requests_present = all_requests.present?
    @comments_present = contest.notes.present?
    @answer = options[:answer]
    shown_requests = all_requests.by_answer(answer)
    @contest_requests = shown_requests.by_page(options[:page])
    @notes = contest.notes.order(created_at: :desc).includes(:client, :designer).map { |note| ContestNoteView.new(note, options[:current_user]) }
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
    invitable_designers = Designer.includes(portfolio: [:personal_picture]).all
    @invitable_designer_views = invitable_designers.map { |designer| DesignerView.new(designer) }
  end

  attr_reader :contest, :contest_view, :contest_requests, :notes, :reviewer_feedbacks,
              :answer, :view_context

end