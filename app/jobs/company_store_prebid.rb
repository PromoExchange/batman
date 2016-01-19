module CompanyStorePrebid
  @queue = :company_store_prebid

  def self.perform(params)
    company_store = Spree::CompanyStore.where(name: params['name']).first
    fail "Unable to find company store #{params['name']}" if company_store.nil?

    products = Spree::Product.where(supplier: company_store.supplier)
    Rails.logger.info "CSTORE: Preconfiguring products [#{products.count}]"
    products.each do |product|
      Rails.logger.info "CSTORE: Preconfiguring product [#{product.master.sku}]"
      product.preconfigure_auction(company_store)
    end
  end
end
