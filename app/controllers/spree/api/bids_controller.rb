class Spree::Api::BidsController < Spree::Api::BaseController
  before_action :fetch_bid, except: [:index, :create]

  def index
    params[:seller_id] = {} if params[:seller_id].blank?
    params[:auction_id] = {} if params[:auction_id].blank?
    params[:state] = {} if params[:state].blank?
    params[:page] = 1 if params[:page].blank?
    params[:per_page] = 250 if params[:per_page].blank?

    @bids = Spree::Bid.search(
      seller_id_eq: params[:seller_id],
      auction_id_eq: params[:auction_id],
      state_eq: params[:state]
    ).result
      .includes(:seller, :auction, :order)
      .page(params[:page])
      .per(params[:per_page])

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
        @bid.auction.unpaid
      else
        description = "Auction ID: #{@bid.auction.reference}, Buyer: #{@bid.auction.buyer.email}"

        stripe = Stripe::Charge.create(
          amount: @bid.bid.to_i,
          currency: 'usd',
          customer: @bid.auction.customer.token,
          description: description
        )

        if %w(succeeded pending).include?(stripe.status)
          @bid.auction_payments.create(status: stripe.status, charge_id: stripe.id)
          @bid.non_preferred_accept
          @bid.auction.accept
        end
      end
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
    @auction = Spree::Auction.find(json['auction_id'])
    quantity = @auction.quantity
    price = json['per_unit_bid'].to_s
    total = quantity * price.to_f

    # TODO: Not sure about this, this is a float to float comparison
    if @auction.bids.where(seller_id: json['seller_id']).map(&:order).map(&:total).map(&:to_f).include?(total)
      message = 'Bid already created!'
    else
      @bid.assign_attributes(
        auction_id: json['auction_id'],
        seller_id: json['seller_id']
      )
      @bid.save

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

      message = 'Bid created!'
    end
    render 'spree/api/bids/show', json: { message: message }
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
      :state,
      :page,
      :per_page
    )
  end
end
