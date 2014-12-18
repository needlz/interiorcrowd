class ContestRequest < ActiveRecord::Base
  self.per_page = 8

  STATUSES = %w{draft submitted closed fulfillment failed finished}

  validates_inclusion_of :answer, in: %w{no maybe favorite winner}, allow_nil: true
  validates_inclusion_of :status, in: STATUSES, allow_nil: false
  validates_uniqueness_of :designer_id, scope: :contest_id

  belongs_to :designer
  belongs_to :contest
  belongs_to :lookbook

  scope :by_page, ->(page){ paginate(page: page).order(created_at: :desc) }
  scope :active, -> { where(status: ['draft', 'submitted', 'fulfillment']) }

  def moodboard_image_path
    lookbook_item = lookbook.try(:lookbook_details).try(:last)
    return unless lookbook_item
    return lookbook_item.image.image.url if lookbook_item.uploaded?
    return lookbook_item.url if lookbook_item.external?
  end

  def reply(answer, client_id)
    return false unless contest.client_id == client_id
    update_attributes(answer: answer)
  end

  def submitted?
    status == 'submitted'
  end

  def submit!
    update_attributes!(status: 'submitted')
  end

  def draft?
    status == 'draft'
  end
end
