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

  validates_presence_of :hours, :start_date, :due_date, :task
  validate :due_date_after_start_date

  private

  def due_date_after_start_date
    if due_date && start_date && due_date < start_date
      errors.add(:due_date, 'must be after start_date')
    end
  end

end
