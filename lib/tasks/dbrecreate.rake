# Originally written by Justin French (2008):
# http://justinfrench.com/notebook/a-custom-rake-task-to-reset-and-seed-your-database
#
# Modified to work with Rails 3.
# Drops, re-creates and seeds the development database
# Usage: rake db:reseed

namespace :db do
  desc 'Raise an error unless development environment'
  task :dev_only do
    raise 'You can only use this in dev!' unless Rails.env == 'development'
  end

  desc 'Drop, create, migrate then seed the development database'
  task recreate: [
    'environment',
    'db:dev_only',
    'db:drop',
    'db:create',
    'db:migrate',
    'db:seed'
  ]
end
