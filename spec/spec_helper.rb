require 'simplecov'
SimpleCov.start

require 'action_dispatch'
include ActionDispatch::TestProcess

RSpec.configure do |c|
  c.filter_run_excluding need_ups: true
end
