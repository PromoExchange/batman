namespace :scheduler do
  task recalc_price_cache: :environment do
    Spree::CompanyStore.all.each do |company_store|
      Spree::Product.where(supplier: company_store.supplier).each do |product|
        Spree::PriceCache.where(product: product).destroy_all
        product.refresh_price_cache
      end
    end
  end
end
