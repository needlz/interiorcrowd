class ContestRespondView

  attr_reader :contest, :status, :status_name, :answer

  def initialize(respond)
    @status = respond.status
    @status_name = I18n.t('designer_center.responds.statuses.' + respond.status)
    @answer = I18n.t("client_center.entries.answers.#{ respond.answer }") if respond.submitted? && respond.answer
    @contest = ContestShortDetails.new(respond.contest)
  end

end