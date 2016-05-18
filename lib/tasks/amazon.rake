namespace :amazon do
  desc 'configure Cross-Origin Resource Sharing'
  task configure_cors: :environment do
    p ConfigureCors.perform
  end
end

