uri = URI.parse(ENV['REDISCLOUD_URL'])
Resque.redis = Redis.new(url: uri)
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
