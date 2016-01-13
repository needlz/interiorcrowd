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
  config.include Rails.application.routes.url_helpers

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:transaction)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, concurrent: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

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
  Rails.application.routes.default_url_options = { trailing_slash: true, host: 'test.host' }

  config.infer_spec_type_from_file_location!

  class Object
    def concurrent_calls(stubbed_methods, called_method, options={}, &block)
      ActiveRecord::Base.connection.disconnect!
      options.reverse_merge!(count: 2)
      processes = options[:count].times.map do |i|
        ForkBreak::Process.new do |breakpoints|
          ActiveRecord::Base.establish_connection

          # Add a breakpoint after invoking the method
          stubbed_methods.each do |stubbed_method|
            original_method = self.method(stubbed_method)
            self.stub(stubbed_method) do |*args|
              original_method.call(*args)
              breakpoints << stubbed_method
            end
          end

          self.send(called_method)
        end
      end
      block.call(processes)
    ensure
      ActiveRecord::Base.establish_connection
    end
  end

  def dont_raise_i18n_exceptions(&block)
    I18n.exception_handler = lambda { |exception, locale, key, options| }
    if block
      block.call
      raise_i18n_exceptions
    end
  end

  def raise_i18n_exceptions
    I18n.exception_handler = lambda do |exception, locale, key, options|
      if exception.is_a?(I18n::MissingTranslation) && key.to_s != 'i18n.plural.rule'
        raise exception.to_exception
      end
    end
  end

  raise_i18n_exceptions

  def sign_in(user)
    if user.kind_of?(Client)
      session[:client_id] = user.id
    elsif user.kind_of?(Designer)
      session[:designer_id] = user.id
    end
  end

  def jobs_with_handler_like(string)
    DelayedJob.by_handler_like(string)
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
          elements_to_avoid: 'Fur',
          entertaining: 1,
          durability: 2,
          preferred_retailers: {
            ikea: true,
            other: 'other'
          }
      }
    }
  end

  def test_card_number
    '4242424242424242'
  end

  def mock_stripe_customer_authentication
    allow_any_instance_of(StripeCustomer).to receive(:stripe_customer) do
      Hashie::Mash.new(stripe_customer_id: 'id')
    end
  end

  def mock_stripe_successful_charge
    allow_any_instance_of(StripeCustomer).to receive(:charge) do
      Hashie::Mash.new(id: 'charge_id')
    end
  end

  def mock_stripe_unsuccessful_charge
    allow_any_instance_of(StripeCustomer).to receive(:charge) do
      raise Stripe::StripeError.new('error!')
    end
  end

  def mock_stripe_customer_registration
    allow(Stripe::Customer).to receive(:create) do
      Hashie::Mash.new(id: 'customer id')
    end
  end

  def mock_stripe_card_adding
    allow_any_instance_of(StripeCustomer).to receive(:import_card) do
      Hashie::Mash.new(stripe_customer_id: 'id')
    end
  end

  def mock_stripe_setting_default_card
    allow_any_instance_of(StripeCustomer).to receive(:set_default) do
      Hashie::Mash.new(stripe_customer_id: 'id')
    end
  end

  def mock_stripe_card_updating
    allow_any_instance_of(StripeCustomer).to receive(:update_card) do
      Hashie::Mash.new(stripe_customer_id: 'id')
    end
  end

  def mock_stripe_card_deleting
    allow_any_instance_of(StripeCustomer).to receive(:delete_card) do
      Hashie::Mash.new(stripe_customer_id: 'id')
    end
  end

  def pay_contest(contest)
    payment = Payment.new(contest)
    mock_stripe_customer_registration
    mock_stripe_successful_charge
    payment.perform
  end

  def credit_card_attributes
    { number: '4012 8888 8888 1881',
      ex_month: '12',
      ex_year: (Time.current.year + 5).to_s,
      cvc: '123',
      name_on_card: 'John Dou',
      address: 'Address',
      city: 'City',
      state: 'State',
      zip: '12345',
    }
  end

  def mock_pubsub
    allow_any_instance_of(Ably::Rest::Channel).to receive(:publish)
  end

  def mock_stripe_cards_retrievement
    allow_any_instance_of(StripeCustomer).to receive(:delete_card) do
      Hashie::Mash.new(stripe_customer_id: 'id')
    end
  end

end
