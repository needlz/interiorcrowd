source 'https://rubygems.org'

ruby '2.3.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'

gem 'passenger' # webserver

gem 'activerecord-session_store', git: 'https://github.com/rails/activerecord-session_store.git'

gem 'pg'
gem "paperclip", "~> 3.0"
gem 'mime-types'
gem "will_paginate", "~> 3.0.4"
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'figaro'
gem 'haml'
gem 'devise'
gem 'jquery-ui-rails'
gem 'aws-sdk', '< 2.0' # incompatibility with SDK v2
gem 'hashie'
gem 'fabrication'
gem 'sprockets', '~> 2.11.0'
gem 'state_machine'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'jquery-fileupload-rails'
gem 'rails_autolink'
gem 'email_validator'
gem 'active_record_union'
gem 'jquery-slick-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :production, :staging do
  gem 'rails_12factor'
end

group :development do
  gem 'bullet'
  gem 'erb2haml'
  gem 'haml-rails'
  gem 'sass-rails-source-maps'
  gem 'rails_best_practices'
  gem 'lol_dba'  #https://github.com/plentz/lol_dba
  gem 'parallel_tests'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
end

group :test do
  gem 'rspec-rails'
  gem 'stripe-ruby-mock', '~> 2.2.0', require: 'stripe_mock'
  gem 'rspec_junit_formatter', '0.2.2' # test metadata collection for CircleCI
  gem 'simplecov', require: false
  gem 'webmock'
end

gem 'faker' # generating fake data

gem 'mandrill-rails'
gem 'mandrill-api'

gem 'rollbar', '~> 1.4.2' #error notifier
gem 'social-share-button'
gem 'numbers_and_words' #humanize numbers output
gem 'activeadmin', '~> 1.0.0.pre1'
gem 'rubyzip', '>= 1.0.0'
gem 'money-rails' # parses currency input
gem 'attribute_normalizer'
gem 'mixpanel-ruby' # analytics tool
gem 'annotate', '~> 2.6.6' # add a comment summarizing the current schema of models
gem 'heroku-api'
gem 'i18n-js', '>= 3.0.0.rc8'
gem 'awesome_print', require: 'ap'
gem 'dotiw' # better distance of time in words
gem 'stripe'
gem 'ably-rest'
gem 'pgbackups-archive'
gem 'omniauth-facebook'
gem 'koala', '~> 2.0'
gem 'faraday_middleware'
gem 'faraday-cookie_jar'
gem 'http-cookie'
gem 'newrelic_rpm'
gem 'fork_break'
gem 'database_cleaner'
gem 'rack-ssl-enforcer'
gem 'griddler' # parses email text
gem 'viglink-api'
gem 'sitemap_generator'
gem 'postoffice'
gem 'gibbon'
gem 'ruby_dig'
gem 'timecop'

# profiling
gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof'
gem 'memory_profiler'
gem 'lograge'

