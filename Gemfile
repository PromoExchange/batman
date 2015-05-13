ruby '2.2.2'
source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'pg'
gem 'unicorn'

# spree ecommerce
gem 'spree', '3.0.1'
gem 'spree_gateway', github: 'spree/spree_gateway', branch: '3-0-stable'
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '3-0-stable'
gem 'spree_i18n', git: 'git://github.com/spree/spree_i18n.git', branch: '3-0-stable'
gem 'deface', git: 'git://github.com/spree/deface.git', branch: 'master'

# PX Extension
gem 'spree_px_auction', git: "https://49887dcddfed712f0ae9a296756a31df77ae0d1e:x-oauth-basic@github.com/PromoExchange/spree_px_auction.git", branch: 'master'

gem 'aws-sdk'

gem 'spree_first_data_gge4'

group :development do
  gem 'rubocop', require: false
  gem 'byebug'
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
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'rspec-rails'
  gem 'dotenv-rails'
end

group :production do
  gem 'rails_12factor'
  gem 'unicorn-worker-killer'
  gem 'newrelic_rpm'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda'
end
