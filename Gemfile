ruby '2.2.3'
source 'https://rubygems.org'

gem 'rails', '4.2.2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'pg'
gem 'unicorn'
gem 'font-awesome-sass'
gem 'local_time'
gem 'aws-sdk', '< 2.0'
gem 'awesome_print', '~> 1.2.0'
gem 'redis'
gem 'redis-rails'
gem 'resque'
gem 'resque-scheduler', '~> 3.1.0'
gem 'paperclip'
gem 'stripe'
gem 'active_shipping'
gem 'humanize_boolean'
gem 'state_machine'
gem 'oj'
gem 'le'
gem 'kaminari'
gem 'httparty'
gem 'remotipart'
gem 'slim', '~> 3.0', '>= 3.0.6'
gem 'nokogiri'
gem 'ruby-prof'
gem 'slack-notifier'

# spree ecommerce
gem 'spree', '3.0.5'
gem 'spree_gateway',        github: 'spree/spree_gateway', branch: '3-0-stable'
gem 'spree_auth_devise',    github: 'spree/spree_auth_devise', branch: '3-0-stable'
gem 'spree_volume_pricing', github: 'spree/spree_volume_pricing', branch: '3-0-stable'
gem 'spree_i18n',           github: 'spree-contrib/spree_i18n', branch: '3-0-stable'
gem 'spree_first_data_gge4'
gem 'deface', git: 'git://github.com/spree/deface.git', branch: 'master'

group :development do
  gem 'rubocop', require: false
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'terminal-notifier-guard', '~> 1.6.1'
  gem 'annotate', '~> 2.6.6'
  gem 'better_errors'
  gem 'binding_of_caller', platforms: [:mri_21]
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-livereload', require: false
  gem 'quiet_assets'
  gem 'rb-fchange', require: false
  gem 'rb-fsevent', require: false
  gem 'rb-inotify', require: false
  gem 'spring-commands-rspec'
  gem 'letter_opener'
  gem 'letter_opener_web', '~> 1.2.0'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'launchy'
end

group :production, :staging do
  gem 'rails_12factor'
  gem 'unicorn-worker-killer'
  gem 'newrelic_rpm'
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'simplecov', require: false
end
