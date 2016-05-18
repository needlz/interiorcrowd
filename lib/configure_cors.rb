class ConfigureCors < Action

  def perform
    s3 = AWS::S3.new
    bucket_name = Settings.aws.bucket_name
    bucket = s3.buckets[bucket_name]
    url = URI(Settings.app_url)

    bucket.cors = ({ allowed_methods: ["POST", "GET", "HEAD"],
                     allowed_origins: ["#{ url.scheme }://#{ url.host }"],
                     allowed_headers: ["accept", "Content-Type", "Content-Type", "Content-Range", "Content-Disposition", "Content-Description"],
                     expose_headers: ["Content-Type", "Content-Range", "Content-Disposition", "Content-Description", "Accept"],
                     max_age_seconds: 1,
    })
  end

end
