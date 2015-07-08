namespace :worker do
  desc 'restarts heroku worker'
  task restart: :environment do
    heroku_api = Heroku::API.new(api_key: ENV['HEROKU_API_KEY'])
    heroku_api.post_ps_restart(ENV['APP_NAME'], ps: 'worker.1')
  end
end
