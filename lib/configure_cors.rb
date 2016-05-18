class ConfigureCors < Action

  def perform
    s3 = AWS::S3.new
    bucket_name = Settings.aws.bucket_name
    bucket = s3.buckets[bucket_name]

    bucket.cors = ({ allowed_methods: ["POST", "GET", "HEAD"],
                     allowed_origins: ["http://localhost:3000*"],
                     allowed_headers: ["accept", "Content-Type", "Content-Type", "Content-Range", "Content-Disposition", "Content-Description"],
                     expose_headers: ["Content-Type", "Content-Range", "Content-Disposition", "Content-Description", "Accept"],
                     max_age_seconds: 1,
    })
  end

end
