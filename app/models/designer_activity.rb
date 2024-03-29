# == Schema Information
#
# Table name: designer_activities
#
#  id              :integer          not null, primary key
#  start_date      :datetime
#  due_date        :datetime
#  task            :string
#  hours           :integer
#  time_tracker_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class DesignerActivity < ActiveRecord::Base

  belongs_to :time_tracker
  has_many :comments, class_name: 'DesignerActivityComment'
  normalize_attributes :task

  validates_presence_of :hours, :start_date, :due_date, :task, message: "Following field can't be blank"
  validate :due_date_after_start_date, :dates_in_week_range

  private

  def due_date_after_start_date
    return unless due_date && start_date
    if due_date < start_date
      errors.add(:due_date, 'must be after start_date')
    end
  end

  def dates_in_week_range
    return unless due_date && start_date
    if (due_date.to_datetime - start_date.to_datetime).to_i.days > 1.week
       errors.add(:due_date, 'Please add one week at a time.')
    end
  end
end
