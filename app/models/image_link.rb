# == Schema Information
#
# Table name: image_links
#
#  id         :integer          not null, primary key
#  contest_id :integer
#  url        :text
#

class ImageLink < ActiveRecord::Base

  belongs_to :contest

end
