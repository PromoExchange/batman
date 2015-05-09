require 'unicorn'
require 'unicorn/worker_killer'
use Unicorn::WorkerKiller::MaxRequests, 150, 250

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
