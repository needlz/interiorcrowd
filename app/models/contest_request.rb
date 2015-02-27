class ContestRequest < ActiveRecord::Base
  self.per_page = 8

  STATUSES = %w{draft submitted closed fulfillment fulfillment_ready fulfillment_approved failed finished}

  validates_inclusion_of :answer, in: %w{no maybe favorite winner}, allow_nil: true
  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_uniqueness_of :designer_id, scope: :contest_id
  validate :contest_status, :one_winner, :allowed_answer, if: ->(request){ request.contest }

  after_update :change_status

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

    event :ready_fulfillment do
      transition fulfillment: :fulfillment_ready
    end

    event :fail_fulfillment do
      transition fulfillment: :failed
    end

    event :approve_fulfillment do
      transition fulfillment_ready: :fulfillment_approved
    end

    event :finish do
      transition fulfillment_approved: :finished
    end
  end

  belongs_to :designer
  belongs_to :contest
  belongs_to :lookbook
  has_many :comments, class_name: 'ConceptBoardComment'
  has_many :image_items
  has_many :product_items, ->{ product_items }, class_name: 'ImageItem'
  has_many :similar_styles, ->{ similar_styles }, class_name: 'ImageItem'

  scope :by_page, ->(page){ paginate(page: page).order(created_at: :desc) }
  scope :active, -> { where(status: ['draft', 'submitted', 'fulfillment', 'fulfillment_ready', 'fulfillment_approved']) }
  scope :view_on_board, -> { where(status: ['draft', 'submitted', 'fulfillment', 'fulfillment_ready', 'fulfillment_approved', 'closed']) }
  scope :published, -> { where(status: ['submitted', 'fulfillment']) }
  scope :submitted, ->{ where(status: 'submitted') }
  scope :fulfillment, ->{ where(status: ['fulfillment', 'fulfillment_ready', 'fulfillment_approved']) }
  scope :by_answer, ->(answer){ answer.present? ? where(answer: answer) : all }
  scope :with_design_properties, -> {includes(contest: [:design_category, :design_space])}

  def change_status
    if (changed_to?(:answer, 'winner') && status == 'submitted')
      winner!
      notify_designer_about_win
      contest.winner_selected!
    end
  end

  def moodboard_image_path
    lookbook_item = lookbook.try(:lookbook_details).try(:last)
    return unless lookbook_item
    return lookbook_item.image.original_size_url if lookbook_item.uploaded? && lookbook_item.try(:image)
    return lookbook_item.url if lookbook_item.external?
  end

  def concept_board_image
    lookbook_item = lookbook.try(:lookbook_details).try(:last)
    return unless lookbook_item
    lookbook_item.image if lookbook_item.uploaded? && lookbook_item.try(:image)
  end

  def reply(answer, client_id)
    return if status == 'fulfillment'
    (contest.client_id == client_id) && update_attributes(answer: answer)
  end

  def answerable?
    contest.responses_answerable?
  end

  def approve
    return false if fulfillment_approved?
    transaction do
      DesignerInfoNotification.create(user_id: designer_id, contest_id: contest_id, contest_request_id: id)
      approve_fulfillment!
    end
  end

  def fulfillment_editing?
    fulfillment? || fulfillment_ready? || fulfillment_approved?
  end

  def commenting_enabled?
    fulfillment_editing?
  end

  def basic_editing_only?
    draft?
  end

  def contest_owner?(user)
    contest.client == user
  end

  def download_url
    s3_object = concept_board_image.image.s3_object
    s3_object.url_for(:get, expires: 20.seconds, response_content_disposition: 'attachment;').to_s
  end

  private

  def contest_status
    if (changed_to?(:status, 'submitted') || contest_id_changed?) && !contest.submission?
      errors.add(:status, I18n.t('contest_requests.validations.contest_submission'))
    end
  end

  def allowed_answer
    if !answerable? && answer.present? && answer_changed?
      errors.add(:answer, I18n.t('contest_requests.validations.not_answerable'))
    end
  end

  def one_winner
    if changed_to?(:answer, 'winner') && contest.has_other_winners?(id)
      errors.add(:answer, I18n.t('contest_requests.validations.one_winner'))
    end
  end

  def notify_designer_about_win
    DesignerWinnerNotification.create(user_id: designer_id, contest_id: contest_id, contest_request_id: id)
  end
end
