namespace :attachments do
  desc 'clear unused files'
  task clear: :environment do
    UnusedUploadsCleaner.perform
  end
end
