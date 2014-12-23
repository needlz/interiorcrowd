class Contest < ActiveRecord::Base
  self.per_page = 10
  
  CONTEST_DESIGN_BUDGETS = {1 => "$0-$200", 2 => "$201-$500", 3 => "$501-1000", 4 => "$1000+"}
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

  scope :by_page, ->(page) { paginate(page: page).order(created_at: :desc) }
  scope :current, ->{ where(status: 'submission') }

  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_presence_of :design_category
  validates_presence_of :design_space

  after_initialize :defaults, if: :new_record?
  after_commit :delay_submission_end, on: :create

  state_machine :status, initial: :submission do
    event :start_winner_selection do
      transition submission: :winner_selection
    end

    event :close do
      transition submission: :closed
    end

    event :winner_selected do
      transition winner_selection: :fulfillment
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
  end

  def days_left
    submission? ? ((phase_end - Time.current) / 1.day).ceil : 0
  end

  def response_of(designer)
    requests.find_by_designer_id(designer.id)
  end

  def end_submission
    return close! if requests.submitted.count < 3
    start_winner_selection!
  end

  def delay_submission_end
    Contests::SubmissionEndJob.schedule(id, run_at: phase_end)
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

  def calculate_end_submission_date
    Time.current + 3.days
  end

  def defaults
    self.phase_end ||= calculate_end_submission_date
  end
end
