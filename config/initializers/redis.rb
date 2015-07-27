uri = URI.parse(ENV['REDISCLOUD_URL'])
REDIS = Redis.new(url: uri)
