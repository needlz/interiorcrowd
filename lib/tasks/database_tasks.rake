namespace :database do
  desc 'backup and archive to Amazon S3'
  task archive: :environment do
    PgbackupsArchive::Job.call
  end
end
