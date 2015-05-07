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
#  status                          :string(255)      default("submission")
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

  CONTEST_DESIGN_BUDGET_PLAN = {1 => "$99", 2 => "$199", 3 => "$299"}
  STATUSES = %w{submission winner_selection closed fulfillment finished}

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

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }
  scope :current, ->{ where(status: 'submission') }
  scope :active, ->{ where(status: ['submission', 'winner_selection', 'fulfillment']) }
  scope :inactive, ->{ where(status: ['closed', 'finished']) }
  scope :with_associations, ->{ includes(:design_category, :design_space, :client) }

  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_presence_of :design_category
  validates_presence_of :design_space
  normalize_attributes *ContestAdditionalPreference::PREFERENCES.keys
  ContestAdditionalPreference::PREFERENCES.each do |preference, options|
    validates_inclusion_of preference, in: options.map(&:to_s), allow_nil: true
  end

  after_initialize :defaults, if: :new_record?
  after_update :create_phase_end_job
  after_create :create_retailer_preferences, on: :create

  state_machine :status, initial: :submission do
    after_transition on: :close, do: :close_requests
    after_transition on: :winner_selected, do: :close_losers_requests

    event :start_winner_selection do
      transition submission: :winner_selection
    end

    event :close do
      transition submission: :closed, winner_selection: :closed, fullfilment: :closed
    end

    event :winner_selected do
      transition winner_selection: :fulfillment, submission: :fulfillment
    end

    event :finish do
      transition fulfillment: :finished
    end
  end

  def self.create_from_options(options)
    contest = new(options.contest)
    contest.transaction do
      contest.save!
      contest.on_update_from_options(options)
    end
    contest
  end

  def update_from_options(options)
    transaction do
      update_attributes(options.contest) if options.contest
      on_update_from_options(options)
    end
  end

  def on_update_from_options(options)
    return unless options
    update_appeals(options.appeals) if options.appeals
    update_external_examples(options.example_links) if options.example_links
    update_space_images(options.space_image_ids) if options.space_image_ids
    update_example_images(options.liked_example_ids) if options.liked_example_ids
    update_preferred_retailers(options.preferred_retailers) if options.preferred_retailers.present?
  end

  def days_left
    (submission? || winner_selection?) ? ((phase_end - Time.current) / 1.day).ceil : 0
  end

  def response_of(designer)
    requests.find_by_designer_id(designer.id)
  end

  def end_submission
    return close! if requests.submitted.count < 3
    start_winner_selection!
  end

  def end_winner_selection
    return close! if response_winner.blank?
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
      DesignerLoserInfoNotification.create(user_id: request.designer_id, contest_id: request.contest_id, contest_request_id: request.id)
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

  private

  def update_appeals(options)
    Appeal.all.each do |appeal|
      contest_appeal = contests_appeals.where(appeal_id: appeal.id).first_or_initialize
      if options[appeal.identifier]
        contest_appeal.assign_attributes(options[appeal.identifier])
        contest_appeal.save
      end
    end
  end

  def update_external_examples(urls)
    return unless urls
    liked_external_examples.destroy_all
    urls.each do |url|
      liked_external_examples << ImageLink.new(url: url)
    end
  end

  def update_space_images(image_ids)
    Image.update_contest(self, image_ids, Image::SPACE)
  end

  def update_example_images(image_ids)
    Image.update_contest(self, image_ids, Image::LIKED_EXAMPLE)
  end

  def defaults
    current_milestone_info = ContestMilestone.new(self)
    self.phase_end ||= current_milestone_info.phase_end(Time.current)
  end

  def create_retailer_preferences
    update_attributes!(preferred_retailers_id: PreferredRetailers.create!.id)
  end

  def update_preferred_retailers(preferred_retailers_params)
    preferred_retailers.update_attributes!(preferred_retailers_params)
  end

  def create_phase_end_job
    milestone_end_job_updater = ContestMilestoneEndJobUpdater.new(self)
    milestone_end_job_updater.perform
  end

end
