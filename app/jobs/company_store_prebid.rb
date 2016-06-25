module CompanyStorePrebid
  @queue = :company_store_prebid

  def self.perform(params)
    company_store = Spree::CompanyStore.where(name: params['name']).first
    raise "Unable to find company store #{params['name']}" if company_store.nil?

    products = Spree::Product.where(supplier: company_store.supplier)
    Rails.logger.info "CSTORE: Preconfiguring products [#{products.count}]"
    products.each do |product|
      Rails.logger.info "CSTORE: Preconfiguring product [#{product.master.sku}]"
      product.preconfigure_auction(company_store)
      auction = Spree::Auction.where(state: :custom_auction, product: product).first

      if auction.nil?
        Rails.logger.error "CSTORE: Failed to find auction for [#{product.master.sku}]"
        next
      end

      Rails.logger.info "CSTORE: Creating Prebid for [#{product.master.sku}]"
      Resque.enqueue(CreatePrebids, auction_id: auction.id)
    end
  end
end
