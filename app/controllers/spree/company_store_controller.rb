class Spree::CompanyStoreController < Spree::StoreController
  layout "company_store_layout"
  before_action :fetch_company_store, only: [:show]

  def index
    company_store_id = ENV['COMPANYSTORE_ID']
    redirect_to "/company_store/#{company_store_id}"
  end

  def inspire_me
    BuyerMailer.send_inspire_me_request(params[:inspire_me_request], params[:product_request]).deliver
    flash[:notice] = 'Your PromoExchange swag pro will have product ideas for you soon!'
    render :js => "window.location = '/'"
  end

  private

  def fetch_company_store
    @company_store = Spree::CompanyStore.where(slug: params[:id]).first
    products = Spree::Product.where(supplier: @company_store.supplier)
    @auctions = Spree::Auction.where(product_id: products.pluck(:id), state: :custom_auction).order(:id)
  end

  def company_store_params
    params.require(:company_store).permit(:id,:buyer_id, :title, :request, :budget_from, :budget_to, :quantity, request_type:[])
  end
end
