class ContestResponseView

  attr_reader :contest, :status, :status_name, :answer, :id

  def initialize(response)
    @id = response.id
    @status = response.status
    @status_name = I18n.t('designer_center.responses.statuses.' + response.status)
    @answer = I18n.t("client_center.entries.answers.#{ response.answer }") if response.submitted? && response.answer
    @contest = ContestShortDetails.new(response.contest)
  end

end
