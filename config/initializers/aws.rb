AWS.config({
  access_key_id: ENV['ACCESS_KEY_ID'],
  secret_access_key: ENV['SECRET_ACCESS_KEY'],
  region: ENV['us-east-1'],
})

S3_CS_BUCKET = AWS::S3.new.buckets['px-company-stores']
