module RecalcPriceCache
  @queue = :recalc_price_cache

  def self.perform
    company_store = Spree::CompanyStore.where(slug: 'xactly').first
    Spree::Product.where(supplier: company_store.supplier).each do |product|
      Spree::PriceCache.where(product: product).destroy_all
      product.refresh_price_cache
    end
  end
end
