module Downloadable
  extend ActiveSupport::Concern

  def url_for_downloading
    if Settings.uploads_stored_in_filesystem
      attachment.url
    else
      s3_object = attachment.s3_object
      s3_object.url_for(:get, expires: 1.day, response_content_disposition: 'attachment;').to_s
    end
  end

  def url_for_streaming
    s3_object = attachment.s3_object
    s3_object.url_for(:get).to_s
  end

end
