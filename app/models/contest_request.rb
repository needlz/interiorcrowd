# == Schema Information
#
# Table name: contest_requests
#
#  id                 :integer          not null, primary key
#  designer_id        :integer
#  contest_id         :integer
#  designs            :text
#  feedback           :text
#  created_at         :datetime
#  updated_at         :datetime
#  lookbook_id        :integer
#  answer             :string(255)
#  status             :string(255)      default("draft")
#  final_note         :text
#  pull_together_note :text
#  token              :string(255)
#

class ContestRequest < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  self.per_page = 8

  STATUSES = %w{draft submitted closed fulfillment fulfillment_ready fulfillment_approved failed finished}

  normalize_attributes :answer

  validates_inclusion_of :answer, in: %w{no maybe favorite winner}, allow_nil: true
  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_uniqueness_of :designer_id, scope: :contest_id
  validate :contest_status, :one_winner, :allowed_answer, if: ->(request){ request.contest }

  after_update :change_status
  after_initialize :set_token, if: :new_record?

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
  has_one :sound, dependent: :destroy

  scope :by_page, ->(page){ paginate(page: page).order(created_at: :desc) }
  scope :active, -> { where(status: %w(draft submitted fulfillment fulfillment_ready fulfillment_approved)) }
  scope :ever_published, -> { where(status: %w(closed submitted fulfillment fulfillment_ready fulfillment_approved finished)) }
  scope :submitted, ->{ where(status: %w(submitted)) }
  scope :fulfillment, ->{ where(status: %w(fulfillment fulfillment_ready fulfillment_approved)) }
  scope :finished, ->{ where(status: 'finished') }
  scope :by_answer, ->(answer){ answer.present? ? where(answer: answer) : all }
  scope :with_design_properties, -> {includes(contest: [:design_category, :design_space])}

  def change_status
    selected_as_winner if (changed_to?(:answer, 'winner') && status == 'submitted')
  end

  def concept_board_current_image_path
    current_image = concept_board_current_image
    current_image.original_size_url if current_image
  end

  def concept_board_current_image
    lookbook_item = current_lookbook_item
    return unless lookbook_item
    lookbook_item.image if lookbook_item.uploaded?
  end

  def current_lookbook_item
    return if !lookbook || !lookbook.lookbook_details
    item = nil
    phases_count = ContestPhases::INDICES_TO_PHASES.keys.count
    item_index = (phases_count - 1).downto(0).find do |i|
      item = lookbook.lookbook_details.find_by_phase(ContestPhases.index_to_phase(i))
    end
    item if item_index
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
      DesignerInfoNotification.create(user_id: designer_id,
                                      contest_id: contest_id,
                                      contest_request_id: id)
      PhaseUpdater.new(self).perform_phase_change do
        approve_fulfillment!
      end
    end
  end

  def fulfillment_editing?
    fulfillment? || fulfillment_ready? || fulfillment_approved?
  end

  def commenting_enabled?
    submitted? || fulfillment_editing?
  end

  def details_editable?
    !draft? && editable?
  end

  def contest_owner?(user)
    contest.client == user
  end

  def download_url
    concept_board_current_image.try(:url_for_downloading)
  end

  def lost?
    closed? && contest.status != 'closed'
  end

  def editable?
    !(closed? || finished?) && contest.editable?
  end

  def visible_image_items(for_phase)
    image_items.send(for_phase)
  end

  def concept_board_image_by_phase(phase)
    return if !lookbook || !lookbook.lookbook_details
    lookbook_item = lookbook.lookbook_details.find_by_phase(phase)
    lookbook_item.try(:image)
  end

  def name
    "Concept board #{ id }"
  end

  private

  def contest_status
    if (status == 'submitted') && !(contest.submission? || contest.winner_selection?)
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

  def set_token
    self.token = TokenGenerator.generate
  end

  def selected_as_winner
    select_winner = SelectWinner.new(self)
    select_winner.perform
  end

end
