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
  scope :published, -> { where(status: %w(submitted fulfillment)) }
  scope :submitted, ->{ where(status: %w(submitted)) }
  scope :fulfillment, ->{ where(status: %w(fulfillment fulfillment_ready fulfillment_approved)) }
  scope :finished, ->{ where(status: 'finished') }
  scope :by_answer, ->(answer){ answer.present? ? where(answer: answer) : all }
  scope :with_design_properties, -> {includes(contest: [:design_category, :design_space])}

  def change_status
    selected_as_winner if (changed_to?(:answer, 'winner') && status == 'submitted')
  end

  def concept_board_image_path
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
    submitted? || fulfillment_editing? || true
  end

  def details_editable?
    !draft? && editable?
  end

  def contest_owner?(user)
    contest.client == user
  end

  def download_url
    concept_board_image.try(:url_for_downloading)
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

  def notify_designer_about_win
    DesignerWinnerNotification.create(user_id: designer_id, contest_id: contest_id, contest_request_id: id)
  end

  def set_token
    self.token = TokenGenerator.generate
  end

  def selected_as_winner
    winner!
    notify_designer_about_win
    contest.winner_selected!
    create_default_image_items
  end

  def create_default_image_items
    ImageItem::KINDS.each do |kind|
      unless image_items.where(kind: kind.to_s).exists?
        image_items.create!(text: I18n.t('designer_center.product_items.text_placeholder'), kind: kind.to_s)
      end
    end
  end

end
