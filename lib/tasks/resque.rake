# Resque tasks
require 'resque/tasks'

namespace :resque do
  task setup: :environment do
    require 'resque'
    Resque.redis = Redis.new url: URI.parse(ENV['CACHE_URL'])
  end
end
