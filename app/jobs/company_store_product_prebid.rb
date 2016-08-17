module CompanyStoreProductPrebid
  @queue = :company_store_product_prebid

  def self.perform(params)
    company_store = Spree::CompanyStore.where(slug: params['company_store']).first
    raise "Unable to find company store #{params['name']}" if company_store.nil?

    product = Spree::Product.find(params['id'])
    raise "Unable to find product #{params['id']}" if product.nil?

    Rails.logger.info "CSTORE: Preconfiguring product [#{product.master.sku}]"
    product.preconfigure_auction(company_store)
    auction = Spree::Auction.where(state: :custom_auction, product: product).first

    return Rails.logger.error "CSTORE: Failed to find auction for [#{product.master.sku}]" if auction.nil?

    Rails.logger.info "CSTORE: Creating Prebid for [#{product.master.sku}]"
    Resque.enqueue(CreatePrebids, auction_id: auction.id)
  end
end
