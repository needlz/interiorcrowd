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
#  status                          :string(255)      default("brief_pending")
#  phase_end                       :datetime
#  theme                           :string(255)
#  space                           :string(255)
#  accessories                     :string(255)
#  space_changes                   :string(255)
#  shop                            :string(255)
#  accommodate_children            :boolean
#  accommodate_pets                :boolean
#  retailer                        :text
#  elements_to_avoid               :text
#  entertaining                    :integer
#  durability                      :integer
#  preferred_retailers_id          :integer
#  designers_explore_other_colors  :boolean          default(FALSE)
#  designers_only_use_these_colors :boolean          default(FALSE)
#

class Contest < ActiveRecord::Base

  self.per_page = 10

  STATUSES = %w[brief_pending submission winner_selection closed fulfillment final_fulfillment finished]
  COLLABORATION_STATUSES = %w[submission winner_selection fulfillment]
  NON_FINISHED_STATUSES = ['brief_pending'] + COLLABORATION_STATUSES
  FINISHED_STATUSES = %w[closed finished]

  has_many :contests_appeals
  has_many :appeals, through: :contests_appeals
  has_many :liked_external_examples, class_name: 'ImageLink'

  has_many :images
  has_many :liked_examples, -> { liked_examples }, class_name: 'Image'
  has_many :space_images, -> { space_images }, class_name: 'Image'

  has_many :delayed_jobs

  belongs_to :client
  belongs_to :design_category
  belongs_to :design_space
  has_many :requests, class_name: 'ContestRequest'
  has_many :participants, class_name: 'Designer', through: :requests, source: :designer
  has_many :designer_invite_notifications
  has_many :notes, class_name: 'ContestNote'
  has_many :reviewer_invitations
  has_many :reviewer_feedbacks, through: :reviewer_invitations, source: :feedbacks
  belongs_to :preferred_retailers, class_name: 'PreferredRetailers', foreign_key: :preferred_retailers_id
  has_one :client_payment
  has_many :contest_promocodes
  has_many :promocodes, through: :contest_promocodes

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }
  scope :current, ->{ where(status: 'submission') }
  scope :active, ->{ where(status: COLLABORATION_STATUSES) }
  scope :inactive, ->{ where(status: FINISHED_STATUSES) }
  scope :in_progress, ->{ where(status: NON_FINISHED_STATUSES) }
  scope :with_associations, ->{ includes(:design_category, :design_space, :client) }

  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_presence_of :design_category
  validates_presence_of :design_space
  normalize_attributes *ContestAdditionalPreference::PREFERENCES.keys
  ContestAdditionalPreference::PREFERENCES.each do |preference, options|
    validates_inclusion_of preference, in: options.map(&:to_s), allow_nil: true
  end

  after_update :create_phase_end_job, on: :create
  after_update :update_phase_end_job
  after_create :create_retailer_preferences, on: :create

  state_machine :status, initial: :brief_pending do
    after_transition on: :close, do: :close_requests
    after_transition on: :winner_selected, do: :close_losers_requests

    event :submit do
      transition brief_pending: :submission
    end

    event :start_winner_selection do
      transition submission: :winner_selection
    end

    event :close do
      transition submission: :closed, winner_selection: :closed, fullfilment: :closed
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

  def days_left
    (submission? || winner_selection?) ? ((phase_end - Time.current) / 1.day).ceil : 0
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

  def invite_reviewer(invite_params)
    reviewer_invitations.create!(invite_params)
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
    BudgetPlan.find(budget_plan)
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
