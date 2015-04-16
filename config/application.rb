require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module InteriorC
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.action_controller.permit_all_parameters = true
    %w(mailers middleware view_objects).each do |dir|
      config.autoload_paths << "#{config.root}/app/#{dir}"
    end

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        :address => "smtp.gmail.com",
        :port => 587,
        :domain => "gmail.com",
        :user_name => ENV['mailer_address'], #Your user name
        :password => ENV['mailer_password'], # Your password
        :authentication => "plain",
        :enable_starttls_auto => true
    }

    s3_settings = { bucket: ENV['S3_BUCKET_NAME'],
                    access_key_id: ENV['AWS_ACCESS_KEY'],
                    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }
    config.paperclip_defaults = {
        url: ':s3_domain_url',
        storage: :s3,
        s3_credentials: s3_settings
    }
    AWS.config(s3_settings)

    config.i18n.enforce_available_locales = false
    config.session_store :active_record_store

    Dir.glob("#{Rails.root}/app/assets/fonts/**/").each do |path|
      config.assets.paths << path
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    config.action_mailer.default_url_options = { host: ENV['APP_HOST'] }
  end
end
