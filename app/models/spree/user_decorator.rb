Spree::User.class_eval do
  has_many :logos
  has_many :tax_rates
end
