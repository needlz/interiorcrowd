# == Schema Information
#
# Table name: time_trackers
#
#  id              :integer          not null, primary key
#  hours_suggested :integer          default(0), not null
#  hours_actual    :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contest_id      :integer
#

class TimeTracker < ActiveRecord::Base
  belongs_to :contest
  has_many :designer_activities
  has_many :hourly_payments
  has_and_belongs_to_many :attachments,
                          class_name: 'Image',
                          join_table: 'time_trackers_attachments',
                          association_foreign_key: :attachment_id

  validates :hours_suggested, :numericality => { :greater_than_or_equal_to => 0 }

  def price_per_hour
    Settings.hour_with_designer_price.to_i
  end

  def tracked_hours
    designer_activities.sum(:hours)
  end

  def display_name
    "Time tracker of contest ##{ contest.id } (#{ contest.name })"
  end

end
