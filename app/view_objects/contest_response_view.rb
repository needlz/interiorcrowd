class ContestResponseView

  attr_reader :contest, :status, :status_name, :answer, :id, :header_text, :comments_count

  HEADER_TEXTS = {
    'fulfillment' => I18n.t('designer_center.edit.above_image'),
    'submitted' => I18n.t('designer_center.edit.update_submission')
  }

  def initialize(response)
    @id = response.id
    @status = response.status
    @status_name = I18n.t('designer_center.responses.statuses.' + response.status)
    @answer = I18n.t("client_center.entries.answers.#{ response.answer }") if response.submitted? && response.answer
    @contest = ContestShortDetails.new(response.contest)
    @header_text = HEADER_TEXTS[response.status]
    @comments_count = response.comments.count
  end

end
