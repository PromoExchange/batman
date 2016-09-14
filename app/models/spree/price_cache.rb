class Spree::PriceCache < Spree::Base
  belongs_to :product

  def initialize
    ActiveSupport::Deprecation.warn 'Price Cache is DEPRECATED', caller
    super
  end

  deprecate(*public_instance_methods(false))
end
