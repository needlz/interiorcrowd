# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Settings = Hashie::Mash.new Rails.application.config_for(:settings)
InteriorC::Application.initialize!
