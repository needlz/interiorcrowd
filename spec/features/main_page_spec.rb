require 'rails_helper'
require 'capybara/rspec'
require 'capybara/rails'

Capybara.app_host = Settings.app_url

RSpec.feature 'Main page', type: :feature do

  Capybara::Webkit.configure do |config|
    # Enable debug mode. Prints a log of everything the driver is doing.
    # config.debug = true

    # By default, requests to outside domains (anything besides localhost) will
    # result in a warning. Several methods allow you to change this behavior.

    # Silently return an empty 200 response for any requests to unknown URLs.
    config.block_unknown_urls

    # Allow pages to make requests to any URL without issuing a warning.
    # config.allow_unknown_urls

    # Allow a specific domain without issuing a warning.
    config.allow_url("/")
    # Timeout if requests take longer than 5 seconds
    config.timeout = 10

    # Don't raise errors when SSL certificates can't be validated
    config.ignore_ssl_errors

    # Don't load images
    config.skip_image_loading
  end

  before do
    Capybara.current_driver = :webkit
  end

  scenario 'User opens beta page', js: true do
    visit '/'
    expect(page.driver.error_messages).to be_empty
  end
end
