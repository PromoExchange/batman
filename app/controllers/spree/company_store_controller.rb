class Spree::CompanyStoreController < Spree::StoreController
  layout 'company_store_layout'
  before_action :fetch_company_store, only: [:show]
  before_action :store_view_setup, only: [:show]

  def index
    company_store_id = ENV['COMPANYSTORE_ID']
    company_store_id ||= 'xactly'
    redirect_to "/company_store/#{company_store_id}"
  end

  def inspire_me
    BuyerMailer.send_inspire_me_request(params[:inspire_me_request], params[:product_request]).deliver_now
    flash[:notice] = 'Your PromoExchange swag pro will have product ideas for you soon!'
    render js: "window.location = '/'"
  end

  private

  def fetch_company_store
    @current_company_store = Spree::CompanyStore.where(slug: params[:id]).first
    session[:company_store_id] = @current_company_store.id
    @products = Spree::Product.available.where(supplier: @current_company_store.supplier)
  end

  def company_store_params
    params.require(:company_store).permit(
      :id,
      :buyer_id,
      :title,
      :request,
      :budget_from,
      :budget_to,
      :quantity,
      request_type: []
    )
  end
end
