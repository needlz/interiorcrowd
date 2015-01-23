class DesignerInvitation < ActiveRecord::Base

  belongs_to :contest
  has_one :client, through: :contest
  belongs_to :designer

end
