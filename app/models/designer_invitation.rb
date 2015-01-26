class DesignerInvitation < ActiveRecord::Base

  validates_uniqueness_of :designer_id, scope: :contest_id

  belongs_to :contest
  has_one :client, through: :contest
  belongs_to :designer

end
