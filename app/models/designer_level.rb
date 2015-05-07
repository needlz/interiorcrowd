# == Schema Information
#
# Table name: designer_levels
#
#  id    :integer          not null, primary key
#  level :integer
#  name  :text
#

class DesignerLevel < ActiveRecord::Base

  has_many :clients

end
