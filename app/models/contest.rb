# == Schema Information
#
# Table name: contests
#
#  id                              :integer          not null, primary key
#  desirable_colors                :text
#  undesirable_colors              :text
#  space_budget                    :string(255)
#  feedback                        :text
#  project_name                    :text
#  budget_plan                     :integer
#  client_id                       :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  space_length                    :decimal(10, 2)   default(0.0)
#  space_width                     :decimal(10, 2)   default(0.0)
#  space_height                    :decimal(10, 2)
#  design_category_id              :integer
#  design_space_id                 :integer
#  status                          :string           default("incomplete")
#  phase_end                       :datetime
#  theme                           :string(255)
#  space                           :string(255)
#  accessories                     :string(255)
#  space_changes                   :string(255)
#  shop                            :string(255)
#  accommodate_children            :string(255)
#  accommodate_pets                :string(255)
#  retailer                        :text
#  elements_to_avoid               :text
#  entertaining                    :integer
#  durability                      :integer
#  preferred_retailers_id          :integer
#  designers_explore_other_colors  :boolean          default(FALSE)
#  designers_only_use_these_colors :boolean          default(FALSE)
#  finished_at                     :datetime
#  submission_started_at           :datetime
#  was_in_brief_pending_state      :boolean
#

class Contest < ActiveRecord::Base

  self.per_page = 10

  STATUSES = %w[incomplete brief_pending submission winner_selection closed fulfillment final_fulfillment finished]
  COLLABORATION_STATUSES = %w[submission winner_selection fulfillment final_fulfillment]
  COMPLETED_NON_FINISHED_STATUSES = %w[brief_pending] + COLLABORATION_STATUSES
  INCOMPLETE_STATUSES = %w[incomplete]
  NON_FINISHED_STATUSES = INCOMPLETE_STATUSES + COMPLETED_NON_FINISHED_STATUSES
  FINISHED_STATUSES = %w[closed finished]
  ACCOMMODATION_VALUES = %w[true false]

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals
  has_many :liked_external_examples, class_name: 'ImageLink'

  has_many :images
  has_many :liked_examples, -> { liked_examples }, class_name: 'Image'
  has_many :space_images, -> { space_images }, class_name: 'Image'

  has_many :delayed_jobs

  belongs_to :client
  belongs_to :design_category
  has_and_belongs_to_many :design_spaces
  has_many :requests, class_name: 'ContestRequest'
  has_many :participants, class_name: 'Designer', through: :requests, source: :designer
  has_many :notes, class_name: 'ContestNote'
  has_many :reviewer_invitations
  has_many :reviewer_feedbacks, through: :reviewer_invitations, source: :feedbacks
  belongs_to :preferred_retailers, class_name: 'PreferredRetailers', foreign_key: :preferred_retailers_id
  has_one :client_payment
  has_one :time_tracker
  has_many :contest_promocodes
  has_many :promocodes, through: :contest_promocodes
  has_many :designer_invite_notifications
  has_many :invited_designers, through: :designer_invite_notifications, source: :designer, class_name: 'Designer'
  belongs_to :designer_level

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }
  scope :current, ->{ where(status: 'submission') }
  scope :active, ->{ where(status: COLLABORATION_STATUSES) }
  scope :inactive, ->{ where(status: FINISHED_STATUSES) }
  scope :in_progress, ->{ where(status: NON_FINISHED_STATUSES) }
  scope :with_associations, ->{ includes(:design_category, :design_spaces, :client) }
  scope :not_paid, ->{ includes(:client_payment).where(client_payments: {id: nil}) }
  scope :incomplete, ->{ where(status: INCOMPLETE_STATUSES) }

  ransacker :finished_at_month, formatter: proc { |month|
    date = ActiveAdminExtensions::ContestDetails.ranges_for_month(month)
    contests = Contest.where(finished_at: date..date.next_month).map(&:id)
    contests.present? ? contests : nil
  } do |parent|
    parent.table[:id]
  end

  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_presence_of :design_category, if: -> { completed? }
  validates_presence_of :design_spaces, if: -> { completed? }
  validates :location_zip, postcode_format: { country_code: :us, allow_blank: true }
  ContestAdditionalPreference::PREFERENCES.each do |preference, options|
    validates_inclusion_of preference,
                           in: options.map(&:to_s),
                           allow_nil: true
  end
  validates_inclusion_of :accommodate_children,
                         :accommodate_pets,
                         in: ACCOMMODATION_VALUES,
                         allow_nil: true

  normalize_attributes *ContestAdditionalPreference::PREFERENCES.keys,
                       :accommodate_pets,
                       :accommodate_children,
                       :durability,
                       :entertaining

  after_update :create_phase_end_job, on: :create
  after_update :update_phase_end_job
  after_create :create_retailer_preferences, on: :create

  state_machine :status, initial: :incomplete do
    after_transition on: :close, do: :close_requests
    after_transition on: :winner_selected, do: :close_losers_requests

    event :complete do
      transition incomplete: :brief_pending
    end

    event :submit do
      transition brief_pending: :submission, incomplete: :submission
    end

    event :start_winner_selection do
      transition submission: :winner_selection
    end

    event :close do
      transition submission: :closed, winner_selection: :closed, fulfillment: :closed
    end

    event :winner_selected do
      transition winner_selection: :fulfillment, submission: :fulfillment
    end

    event :final do
      transition fulfillment: :final_fulfillment
    end

    event :finish do
      transition final_fulfillment: :finished
    end
  end

  def response_of(designer)
    requests.find_by_designer_id(designer.id)
  end

  def close_requests
    requests.update_all(status: 'closed')
  end

  def invite(designer_id)
    designer = Designer.find(designer_id)
    raise('Contest needs to be in submission state') unless submission?
    Jobs::Mailer.schedule(:invite_to_contest, [designer, self.client])
    designer_invite_notifications.create!(designer: designer)
  end

  def responses_answerable?
    winner_selection? || submission?
  end

  def designers_invitation_period?
    submission?
  end

  def retailer_value(retailer)
    send("retailer_#{ retailer }")
  end

  def response_winner
    requests.where(answer: 'winner').last
  end

  def has_other_winners?(request_id)
    requests.where(answer: 'winner').where.not(id: request_id).present?
  end

  def losers_requests
    requests
     .where(ContestRequest.arel_table[:answer].eq(nil)
     .or(ContestRequest.arel_table[:answer].not_eq('winner')))
  end

  def close_losers_requests
    return unless losers_requests
    losers_requests.update_all(status: 'closed')
    losers_requests.each do |request|
      DesignerLoserInfoNotification.create(user_id: request.designer_id,
                                           contest_id: request.contest_id,
                                           contest_request_id: request.id)
    end
  end

  def client_name
    client.name
  end

  def editable?
    !(closed? || finished?)
  end

  def subscribed_designers
    query = SubscribedDesignersQuery.new(self)
    query.relation
  end

  def package
    BudgetPlan.find_by_id(budget_plan)
  end

  def name
    project_name
  end

  def submitted_contests
    requests.submitted
  end

  def concept_board_images
    response_winner.try(:current_images)
  end

  def winner_collaboration?
    fulfillment? || final_fulfillment?
  end

  def paid?
    client_payment && client_payment.last_error.nil?
  end

  def completed?
    !incomplete?
  end

  def not_submitted_designers
    designers = Designer.arel_table
    contest_requests = ContestRequest.arel_table

    contest_requests_by_designer = contest_requests.project(Arel.sql('id')).
        where(contest_requests[:contest_id].eq(id).
                  and(contest_requests[:designer_id].eq(designers[:id])))

    Designer.active.includes(:contest_requests).where(contest_requests_by_designer.exists.not)
  end

  def active_admin_name
    "#{ id } #{ project_name }"
  end

  def published?
    (COLLABORATION_STATUSES + FINISHED_STATUSES).include?(status)
  end

  private

  def create_retailer_preferences
    update_attributes!(preferred_retailers_id: PreferredRetailers.create!.id)
  end

  def create_phase_end_job
    if !phase_end
      update_column(:phase_end, ContestMilestone.new(self).phase_end(Time.current))
    end
    if phase_end
      update_milestone_job
    end
  end

  def update_phase_end_job
    if status_changed?
      update_column(:phase_end, ContestMilestone.new(self).phase_end(Time.current))
      update_milestone_job
    end
    if phase_end_changed?
      update_milestone_job
    end
  end

  def update_milestone_job
    milestone_end_job_updater = ContestMilestoneEndJobUpdater.new(self)
    milestone_end_job_updater.perform
  end

end
