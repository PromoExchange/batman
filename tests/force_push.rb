require 'httparty'
require 'byebug'

auth = { username: 'sk_test_BUEgUvIraeg7Not6KPvNXjXL' }
response = HTTParty.get(
  'https://api.stripe.com/v1/customers/cus_7FiITOjbWrvmPs/sources/ba_171CrdIS8RUOHFdcEOpBRWBQ/verify',
  basic_auth: auth
)
byebug
