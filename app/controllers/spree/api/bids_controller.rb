class Spree::Api::BidsController < Spree::Api::BaseController
  before_action :fetch_bid, except: [:index, :create]

  def index
    params[:seller_id] = {} if params[:seller_id].blank?
    params[:auction_id] = {} if params[:auction_id].blank?
    params[:state] = {} if params[:state].blank?

    @bids = Spree::Bid.search(
      seller_id_eq: params[:seller_id],
      auction_id_eq: params[:auction_id],
      state_eq: params[:state]
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
    @bid.update_attributes(state: 'cancelled', cancelled_date: Time.zone.now)
    render nothing: true, status: :ok
  end

  def accept
    @bid.transaction do
      if @bid.auction.preferred?(@bid.seller)
        @bid.preferred_accept
      else
        description = "Auction ID: #{@bid.auction.reference}, Buyer: #{@bid.auction.buyer.email}"
      
        Stripe::Charge.create(
          amount: @bid.bid.to_i,
          currency: 'usd',
          source: params[:token],
          description: description
        )

        @bid.non_preferred_accept
      end
      @bid.auction.accept
      @bid.order.update_attributes(payment_state: 'balance_due')
    end
    Spree::OrderUpdater.new(@bid.order).update
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
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
      :state
    )
  end
end
