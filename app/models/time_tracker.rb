class TimeTracker < ActiveRecord::Base
  belongs_to :contest
  has_many :designer_activities
  has_and_belongs_to_many :attachments,
                          class_name: 'Image',
                          join_table: 'time_trackers_attachments',
                          association_foreign_key: :attachment_id

  validates :hours_suggested, :numericality => { :greater_than_or_equal_to => 0 }

  PRICE_PER_HOUR = 100

  def price_per_hour
    PRICE_PER_HOUR
  end
end
