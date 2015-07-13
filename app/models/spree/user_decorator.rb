Spree::User.class_eval do
  belongs_to :primary_address, class_name: 'Spree::Address'
end
