namespace :sessions do
  desc 'clear old sessions'
  task clear: :environment do
    ActiveRecord::SessionStore::Session.where('updated_at < ?', Time.now.advance(seconds: -Settings.max_session_duration_secs)).delete_all
  end
end
