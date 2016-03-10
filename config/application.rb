require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

rails_root = File.expand_path('../..', __FILE__)
settings_files = Dir.glob("#{ rails_root }/config/settings/**/*.yml")
settings_files.each do |filename|
  erb_preprocessed = ERB.new(File.read(filename)).result
  yaml = YAML.load(erb_preprocessed)

  ['common', Rails.env].each do |env|
    yaml[env].try(:each) do |key, value|
      ENV[key] = value
    end
  end
end

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
    %w[mailers view_objects admin logic/actions logic/models controllers/concerns forms policies].each do |app_dir|
      config.autoload_paths << "#{ config.root }/app/#{ app_dir }"
    end
    %w[lib].each do |dir|
      config.autoload_paths << "#{ config.root }/#{ dir }"
    end

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.action_mailer.default_url_options = { host: ENV['APP_HOST'] }

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

    config.action_controller.default_url_options = { trailing_slash: true }

    config.time_zone = ENV['TIMEZONE']

    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job

    GC::Profiler.enable

    config.action_controller.asset_host = Proc.new { |source, request|
      "#{request.protocol}#{request.host_with_port}"
    }
  end
end
