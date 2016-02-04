# == Schema Information
#
# Table name: contest_requests
#
#  id                      :integer          not null, primary key
#  designer_id             :integer
#  contest_id              :integer
#  designs                 :text
#  feedback                :text
#  status                  :string(255)      default("draft")
#  created_at              :datetime
#  updated_at              :datetime
#  lookbook_id             :integer
#  answer                  :string(255)
#  final_note              :text
#  pull_together_note      :text
#  token                   :string(255)
#  submitted_at            :datetime
#  won_at                  :datetime
#  last_visit_by_client_at :datetime
#  email_thread_id         :string           not null
#

class ContestRequest < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  self.per_page = 8

  STATUSES = %w{draft submitted closed fulfillment_ready fulfillment_approved failed finished}
  FULFILLMENT_STATUSES = %w{fulfillment_ready fulfillment_approved}
  ANSWERS = %w{no maybe favorite winner}

  normalize_attributes :answer

  validates_inclusion_of :answer, in: ANSWERS, allow_nil: true
  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_uniqueness_of :designer_id, scope: :contest_id
  validate :contest_status, :one_winner, :allowed_answer, if: ->(request){ request.contest }

  after_update :change_status
  after_initialize :set_tokens, if: :new_record?

  state_machine :status, initial: :draft do
    event :submit do
      transition draft: :submitted
    end

    event :close do
      transition submitted: :closed
    end

    event :winner do
      transition submitted: :fulfillment_ready
    end

    event :fail_fulfillment do
      transition fulfillment_ready: :failed
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
  has_many :final_notes

  scope :by_page, ->(page){ paginate(page: page).order(created_at: :desc) }
  scope :active, -> { where(status: %w(draft submitted fulfillment_ready fulfillment_approved)) }
  scope :has_designer_comments, -> { joins(:comments).where('concept_board_comments.role = ?', 'Designer').uniq }
  scope :ever_published, -> { where(status: %w(closed submitted fulfillment_ready fulfillment_approved finished)) }
  scope :client_sees_in_entries, -> { has_designer_comments.union(ever_published) }
  scope :submitted, ->{ where(status: %w(submitted)) }
  scope :fulfillment, ->{ where(status: FULFILLMENT_STATUSES) }
  scope :finished, ->{ where(status: 'finished') }
  scope :by_answer, ->(answer){ answer.present? ? where(answer: answer) : all }
  scope :with_design_properties, -> { includes(contest: [:design_category, :design_spaces]) }

  def self.generate_email_thread_id
    TokenGenerator.generate(20)
  end

  def change_status
    selected_as_winner if (changed_to?(:answer, 'winner') && status == 'submitted')
  end

  def concept_board_current_image
    current_images.first
  end

  def concept_board_current_image_path
    concept_board_current_image.try(:original_size_url)
  end

  def current_lookbook_items
    return LookbookDetail.none if !lookbook || !lookbook.lookbook_details
    lookbook.lookbook_details.where(phase: current_phase)
  end

  def current_phase
    ContestPhases.status_to_phase(status)
  end

  def current_images
    current_lookbook_items.includes(:image).map(&:image)
  end

  def reply(answer, client_id)
    return unless status == 'submitted'
    (contest.client_id == client_id) && update_attributes(answer: answer)
  end

  def answerable?
    contest.responses_answerable? && submitted?
  end

  def fulfillment_editing?
    fulfillment_ready? || fulfillment_approved?
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

  def cover_image(phase)
    return if !lookbook || !lookbook.lookbook_details
    lookbook.lookbook_details.where(phase: phase).order(:created_at).last.try(:image)
  end

  def lookbook_items_by_phase(phase)
    return LookbookDetail.none if !lookbook || !lookbook.lookbook_details
    lookbook.lookbook_details.where(phase: phase)
  end

  def name
    "Concept board #{ id }"
  end

  def collaboration_and_final_comments_count
    comments.count + final_notes.count
  end

  def designers_submission_comments_count
    comments.by_designer.count + (feedback.present? ? 1 : 0)
  end

  def designers_submission_comments_present?
    comments.by_designer.present? || feedback.present?
  end

  def parent_comment(comment)
    comments.where('created_at < ?', comment.created_at).order(:created_at).first
  end

  private

  def contest_status
    if (status == 'submitted') && !(contest.submission? || contest.winner_selection?)
      errors.add(:status, I18n.t('contest_requests.validations.contest_submission'))
    end
  end

  def allowed_answer
    if !contest.responses_answerable? && answer.present? && answer_changed?
      errors.add(:answer, I18n.t('contest_requests.validations.not_answerable'))
    end
  end

  def one_winner
    if changed_to?(:answer, 'winner') && contest.has_other_winners?(id)
      errors.add(:answer, I18n.t('contest_requests.validations.one_winner'))
    end
  end

  def set_tokens
    self.token = TokenGenerator.generate
    self.email_thread_id = ContestRequest.generate_email_thread_id
  end

  def selected_as_winner
    SelectWinner.perform(self)
  end

end
