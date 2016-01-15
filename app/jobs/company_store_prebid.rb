module CompanyStorePrebid
  @queue = :company_store_prebid

  def self.perform(params)
    company_store = Spree::CompanyStore.where(name: params['name']).first
    fail "Unable to find company store #{params['name']}" if company_store.nil?

    products = Spree::Product.where(supplier: company_store.supplier)
    products.each do |product|
      product.pre_configure
    end
  end
end
