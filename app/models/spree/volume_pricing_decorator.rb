Spree::VolumePrice.class_eval do
  after_save :clear_cache

  def clear_cache
    variant.product.clear_cache
  end
end
