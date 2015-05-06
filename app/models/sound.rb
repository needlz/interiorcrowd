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
