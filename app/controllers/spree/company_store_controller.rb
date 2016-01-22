class Spree::CompanyStoreController < Spree::StoreController
  layout "company_store_layout"
  before_action :fetch_company_store, only: [:show]

  def index
    company_store_id = ENV['COMPANYSTORE_ID']
    redirect_to "/company_store/#{company_store_id}"
  end

  private

  def fetch_company_store
    @company_store = Spree::CompanyStore.where(slug: params[:id]).first
    products = Spree::Product.where(supplier: @company_store.supplier).pluck(:id)
    @auctions = Spree::Auction.where(product_id: products, state: :custom_auction)
  end

  def company_store_params
    params.require(:company_store).permit(:id)
  end
end
