class SelectWinner

  def initialize(contest_request)
    @contest_request = contest_request
  end

  def perform
    contest_request.winner!
    contest_request.contest.winner_selected!
    create_default_image_items
    notify_designer_about_win
  end

  private

  attr_reader :contest_request

  def notify_designer_about_win
    DesignerWinnerNotification.create(user_id: contest_request.designer_id,
                                      contest_id: contest_request.contest_id,
                                      contest_request_id: contest_request.id)
    Jobs::Mailer.schedule(:notify_designer_about_win, [contest_request])
  end

  def create_default_image_items
    ImageItem::KINDS.each do |kind|
      unless contest_request.image_items.where(kind: kind.to_s).exists?
        contest_request.image_items.create!(text: I18n.t('designer_center.product_items.text_placeholder'),
                                            kind: kind.to_s)
      end
    end
  end

end
