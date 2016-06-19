# Resque tasks
require 'resque/tasks'

namespace :resque do
  task setup: :environment do
    ENV['QUEUE'] ||= '*'
  end
end
