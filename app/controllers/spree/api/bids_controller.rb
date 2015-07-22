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
    params.require(:bid).permit(
      :auction_id,
      :seller_id,
      :prebid_id,
      :per_unit_bid,
      :order_id,
      :per_page)
  end

  def fetch_bid
    @bid = Spree::Bid.find(params[:id])
  end

  def save_bid
    json = JSON.parse(request.body.read)
    @bid.assign_attributes(
      auction_id: json['auction_id'],
      seller_id: json['seller_id']
    )
    @bid.save
    price = json['per_unit_bid'].to_s
    quantity = @bid.auction.quantity
    unless json['per_unit_bid'].nil?
      li = Spree::LineItem.create(
        currency: 'USD',
        order_id: @bid.order.id,
        quantity: quantity,
        variant: @bid.auction.product.master
      )

      li.price = price
      li.save

      order_updater = Spree::OrderUpdater.new(@bid.order)
      order_updater.update
    end

    render 'spree/api/bids/show'
  rescue
    render nothing: true, status: :bad_request
  end
end
