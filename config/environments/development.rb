InteriorC::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.middleware.use Rack::SslEnforcer,
                        :redirect_to => 'https://localhost',
                        :https_port => 9292,
                        :http_port => 3000,
                        :except => ['/blog', '/designer_submission'],
                        :strict => true

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: 'localhost',
                                         port: 1025 }

  config.action_mailer.perform_deliveries = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Enable source maps in the browser
  config.sass.debug_info = true

  config.action_view.raise_on_missing_translations = true
end
