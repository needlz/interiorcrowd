class ContestRequest < ActiveRecord::Base
  self.per_page = 8

  STATUSES = %w{draft submitted closed fulfillment failed finished}

  validates_inclusion_of :answer, in: %w{no maybe favorite winner}, allow_nil: true
  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_uniqueness_of :designer_id, scope: :contest_id
  validate :contest_status, if: ->(request){ request.contest }
  validate :answerable, if: ->(request){ request.contest }

  state_machine :status, initial: :draft do
    event :submit do
      transition draft: :submitted
    end

    event :close do
      transition submitted: :closed
    end

    event :winner do
      transition submitted: :fulfillment
    end

    event :fail_fulfillment do
      transition fulfillment: :failed
    end

    event :finish do
      transition fulfillment: :finished
    end
  end

  belongs_to :designer
  belongs_to :contest
  belongs_to :lookbook

  scope :by_page, ->(page){ paginate(page: page).order(created_at: :desc) }
  scope :active, -> { where(status: ['draft', 'submitted', 'fulfillment']) }
  scope :submitted, ->{ where(status: 'submitted') }

  def moodboard_image_path
    lookbook_item = lookbook.try(:lookbook_details).try(:last)
    return unless lookbook_item
    return lookbook_item.image.image.url if lookbook_item.uploaded?
    return lookbook_item.url if lookbook_item.external?
  end

  def reply(answer, client_id)
    (contest.client_id == client_id) && update_attributes(answer: answer)
  end

  private

  def contest_status
    if (status_changed_to_submitted? || contest_id_changed?) && !contest.submission?
      errors.add(:status, I18n.t('contest_requests.validations.contest_submission'))
    end
  end

  def answerable
    if !contest.winner_selection? && answer.present?
      errors.add(:answer, I18n.t('contest_requests.validations.not_answerable'))
    end
  end

  def status_changed_to_submitted?
    submitted? && status_changed?
  end

end
