# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

if !Rails.env.development?
  Rails.logger = Le.new(ENV['LOGENTRIES_KEY'])
else
  Rails.logger = Le.new(ENV['LOGENTRIES_KEY'], debug: true, local: true)
end
