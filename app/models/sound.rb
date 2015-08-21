# == Schema Information
#
# Table name: sounds
#
#  id                 :integer          not null, primary key
#  contest_request_id :integer
#  audio_file_name    :string(255)
#  audio_content_type :string(255)
#  audio_file_size    :integer
#  audio_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#

class Sound < ActiveRecord::Base
  include Downloadable

  has_attached_file :audio,
                    path: ':class/:id/:style:filename'

  belongs_to :contest_request

  def name
    "Sound #{ id }"
  end

  private

  def attachment
    audio
  end

end
