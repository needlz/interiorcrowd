# == Schema Information
#
# Table name: appeals
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class Appeal < ActiveRecord::Base

  has_many :contests_appeals
  has_many :contests, through: :contests_appeals

  def identifier
    name.to_sym
  end

end
