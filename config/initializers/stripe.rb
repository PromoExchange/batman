Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key:      ENV['STRIPE_SECRET_KEY']
}

pk_env = Rails.configuration.stripe[:publishable_key][3..6]
sk_env = Rails.configuration.stripe[:secret_key][3..6]
if ( pk_env == 'test' || sk_env == 'test' )
  raise "Attempting to run TEST stripe in production" if Rails.env.production?
else
  raise "Attempting to run LIVE stripe in non production" unless Rails.env.production?
end
raise "Both Stripe settings must point to same location" if sk_env != pk_env

Stripe.api_key = Rails.configuration.stripe[:secret_key]
