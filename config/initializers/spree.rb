# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made
#       through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# Note: If a preference is set here it will be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will not make the preference value go away.
#       Instead you must either set a new value or remove entry, clear cache, and remove database entry.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  config.track_inventory_levels = false
  config.logo = 'logo/px_logo.png'
  config.currency = 'USD'
  config.products_per_page = 12
  config.company = true
end

Spree::Auth::Config.set(signout_after_password_change: true)

Spree.user_class = 'Spree::User'

Rails.application.config.spree.payment_methods << Spree::Gateway::FirstdataE4

Spree::PermittedAttributes.user_attributes << :company

Spree::OptionMapping.whitelisted_ransackable_attributes |= [
  'dc_acct_num',
  'dc_name',
  'px_name'
]

Spree::PmsColor.whitelisted_ransackable_attributes = [
  'display_name',
  'hex',
  'pantone'
]

Spree::Product.whitelisted_ransackable_attributes |= [
  'state',
  'supplier_name',
  'supplier_dc_acct_num',
  'supplier_name_or_supplier_dc_acct_num'
]
Spree::Product.whitelisted_ransackable_associations |= ['supplier']

Spree::Supplier.whitelisted_ransackable_attributes |= ['id', 'name', 'dc_acct_num']

{
  s3_credentials: {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    bucket: ENV['S3_IMAGE_BUCKET']
  },
  storage: :s3,
  s3_headers: { 'Cache-Control' => 'max-age=31557600' },
  s3_protocol: 'https',
  bucket: ENV['S3_IMAGE_BUCKET'],
  url: ':s3_domain_url',
  styles: {
    mini: '48x48>',
    small: '100x100>',
    product: '240x240>',
    large: '600x600>'
  },
  path: '/:class/:id/:style/:basename.:extension',
  default_url: '/:class/:id/:style/:basename.:extension',
  default_style: 'product'
}.each do |key, value|
  Spree::Image.attachment_definitions[:attachment][key.to_sym] = value
end
