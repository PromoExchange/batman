class Spree::InvoicesController < Spree::StoreController
  before_action :require_login
  before_action :fetch_auction, except: [:index]

  def index
    params[:status] = 'unpaid' if params[:status].blank?

    statuses = params[:status].split(',')

    @auctions = Spree::Auction.search(
      seller_id_eq: params[:seller_id],
      status_in: statuses
    ).result

    render 'spree/invoices/index'
  end

  def show
    render 'spree/invoices/show'
  end

  private

  def fetch_auction
    @auction = Spree::Auction.find(params[:id])
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def invoice_params
    params.require(:seller_id).permit(:status, :auction_id)
  end
end
