class ContestResponseView

  attr_reader :contest, :status, :status_name, :answer, :id, :header_text, :collaboration_and_final_comments_count, :image_items

  delegate :draft?, :closed?, to: :response

  HEADER_TEXTS = {
    'fulfillment_ready' => I18n.t('designer_center.edit.above_image'),
    'submitted' => I18n.t('designer_center.edit.update_submission')
  }

  def self.for_responses(responses)
    responses.map{ |response| new(response) }
      .sort_by{ |response| response.contest.days_count.to_i }
      .reverse
  end

  def initialize(response)
    @response = response
    @id = response.id
    @status = response.status
    @status_name = ContestResponseView.status_name(response.status)
    @answer = I18n.t("client_center.entries.answers.#{ response.answer }") if response.submitted? && response.answer
    @contest = ContestShortDetails.new(response.contest)
    @header_text = HEADER_TEXTS[response.status]
    @comments_count = response.collaboration_and_final_comments_count
    @image_items = response.image_items.for_view
  end
  
  def current_phase_index
    ContestPhases.status_to_index(response.status)
  end

  def initial_concept_board?
    current_phase_index == 0
  end

  def self.status_name(status)
    I18n.t('designer_center.responses.statuses.' + status)
  end

  def channel_name
    InstantFeedbackPublisher.channel_name(response.id)
  end

  def design_name
    if response.contest.client.first_name.present?
      response.contest.client.first_name.possessive + ' ' + contest.design_space_possesive_name
    elsif response.contest.client.last_name.present?
      response.contest.client.last_name.possessive + ' ' + contest.design_space_possesive_name
    else
      response.contest.client.email + "'s " + contest.design_space_possesive_name
    end
  end

  private

  attr_reader :response

end
