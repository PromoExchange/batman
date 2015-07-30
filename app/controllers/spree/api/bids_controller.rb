class Spree::Api::BidsController < Spree::Api::BaseController
  before_action :fetch_bid, except: [:index, :create]

  def index
    params[:seller_id] = {} if params[:seller_id].blank?
    params[:auction_id] = {} if params[:auction_id].blank?
    params[:status] = {} if params[:status].blank?

    @bids = Spree::Bid.search(
      seller_id_eq: params[:seller_id],
      auction_id_eq: params[:auction_id],
      status_eq: params[:status]
    ).result
      .includes(:seller)

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
    @bid.update_attributes(status: 'cancelled', cancelled_date: Time.zone.now)
    render nothing: true, status: :ok
  end

  def accept
    @bid.transaction do
      @bid.update_attributes(status: 'accepted')
      @bid.auction.update_attributes(status: 'unpaid')
    end
    Resque.enqueue_at(3.days.from_now, UnpaidInvoice, auction_id: @bid.auction.id)
    Resque.enqueue(SendInvoice, auction_id: @bid.auction.id)
    render nothing: true, status: :ok
  end

  private

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

  def bid_params
    params.require(:bid).permit(
      :auction_id,
      :seller_id,
      :prebid_id,
      :per_unit_bid,
      :order_id,
      :status
    )
  end
end
