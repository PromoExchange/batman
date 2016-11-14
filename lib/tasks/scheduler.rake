namespace :scheduler do
  task recalc_price_cache: :environment do
    scheduled_refresh_cache
  end

  def scheduled_refresh_cache
    return unless Time.zone.now.hour % 6 == 0
    Spree::CompanyStore.all.each do |company_store|
      Spree::Product.where(supplier: company_store.supplier).each do |product|
        product.clear_cache
        product.price_breaks.each do |price_break|
          lowest_range = price_break.split('..')[0].gsub(/\D/, '').to_i
          product.best_price(
            quantity: lowest_range,
            shipping_option: :ups_ground
          )
        end
      end
    end
  end
end
