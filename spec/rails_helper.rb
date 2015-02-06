# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe ClientsController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  def sign_in(user)
    if user.kind_of?(Client)
      session[:client_id] = user.id
    elsif user.kind_of?(Designer)
      session[:designer_id] = user.id
    end
  end

  def contest_options_source
    @contest_options_source ||= { design_brief: {
        design_category: Fabricate(:design_category).id,
        design_area: Fabricate(:design_space).id },
      design_space: {
          length: '2',
          width: '2',
          height: '2',
          length_inches: '10',
          width_inches: '9',
          height_inches: '3',
          f_budget: '2000',
          feedback: 'feedback',
          document_id: [Fabricate(:image).id, Fabricate(:image).id].join(',') },
      preview: {
          b_plan: '1',
          contest_name: 'contest_name' },
      design_style: {
          designer_level: 1,
          desirable_colors: '#bbbbbb',
          undesirable_colors: '#aaaaaa,#888888',
          appeals: {
              some_appeal: {
                  reason: 'reason',
                  value: 100} },
          document_id: [Fabricate(:image).id, Fabricate(:image).id].join(','),
          ex_links: ['link1', 'link2'] },
      contest: {
          retailer_ikea: true,
          elements_to_avoid: 'Fur'
      }
    }
  end
end
