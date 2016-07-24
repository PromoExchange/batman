AWS.config({
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  region: 'us-east-1',
})

S3_CS_BUCKET = AWS::S3.new.buckets['px-company-stores']
