module MoodboardCollection
  extend ActiveSupport::Concern

  def setup_moodboard_collection(contest)
    @contest_view = ContestView.new(contest_attributes: contest)
    all_requests = contest.requests.published.includes(:designer, :lookbook)
    @requests_present = all_requests.present?
    @comments_present = contest.notes.present?
    shown_requests = all_requests.by_answer(params[:answer])
    @contest_requests = shown_requests.by_page(params[:page])
    unless @contest_requests.present?
      invitable_designers = Designer.includes(portfolio: [:personal_picture]).all
      @invitable_designer_views = invitable_designers.map { |designer| DesignerView.new(designer) }
    end
    @notes = contest.notes.order(created_at: :desc).includes(:client, :designer).map { |note| ContestNoteView.new(note, current_user) }
    @reviewer_feedbacks = contest.reviewer_feedbacks.includes(:invitation)
  end

end
