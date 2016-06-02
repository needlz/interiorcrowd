module Paperclip

  # do not complain when missing validations
  class Attachment
    def missing_required_validator?
      false
    end
  end

  # skip media type spoof detection
  module Validators
    class MediaTypeSpoofDetectionValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        true
      end
    end
  end

end

paperclip_defaults =
  if Settings.uploads_stored_in_filesystem
    {
      storage: :filesystem
    }
  else
    {
      url: ':s3_domain_url',
      storage: :s3,
      s3_credentials: { bucket: ENV['S3_BUCKET_NAME'],
                        access_key_id: ENV['AWS_ACCESS_KEY'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }
    }
  end
Paperclip::Attachment.default_options.merge! paperclip_defaults
