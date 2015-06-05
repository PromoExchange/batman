class Spree::Api::BidsController < Spree::Api::BaseController
  before_action :fetch_bid, except: [:index, :create]

  def index
    if params[:auction_id].present?
      @bids = Spree::Bid.where(auction_id: params[:auction_id])
        .includes(:seller)
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    else
      @bids = Spree::Bid.all
        .includes(:seller)
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    end
    render 'spree/api/bids/index'
  end

  def show
    render 'spree/api/bids/show'
  end

  def create
    if @bid.present?
      render nothing: true, status: :conflict
    else
      @bid = Spree::Bid.new
      save_bid
    end
  end

  def update
    save_bid
  end

  def destroy
    @bid.destroy
    render nothing: true, status: :ok
  end

  private

  def bid_params
    params.require(:bid).permit(:auction_id,
      :buyer_id,
      :seller_id,
      :description,
      :prebid_id,
      :prebid_id,
      :order_id,
      :per_page)
  end

  def fetch_bid
    @bid = Spree::Bid.find(params[:id])
  end

  def save_bid
    @json = JSON.parse(request.body.read)
    @bid.assign_attributes(@json)
    if @bid.save
      render 'spree/api/bids/show'
    else
      render nothing: true, status: :bad_request
    end
  end
end
