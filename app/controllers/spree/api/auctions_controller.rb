class Spree::Api::AuctionsController < Spree::Api::BaseController
  before_action :fetch_auction, except: [:index, :create]

  def index
    params[:buyer_id] = {} if params[:buyer_id].blank?
    params[:seller_id] = {} if params[:seller_id].blank?
    params[:state] = 'open' if params[:state].blank?
    params[:page] = 1 if params[:page].blank?
    params[:per_page] = 250 if params[:per_page].blank?

    states = params[:state].split(',')

    if params[:lost].nil?
      @auctions = Spree::Auction.search(
        bids_seller_id_eq: params[:seller_id],
        buyer_id_eq: params[:buyer_id],
        state_in: states
      ).result(distinct: true)
        .includes(:invited_sellers, :review, :bids, :product)
        .page(params[:page])
        .per(params[:per_page])
        .order(:created_at)
    else
      lost_auctions = Spree::Auction.search(
        bids_seller_id_eq: params[:seller_id],
        bids_state_eq: 'lost'
      ).result
      won_auctions = Spree::Auction.search(
        bids_seller_id_eq: params[:seller_id],
        bids_state_eq: 'accepted'
      ).result
      @auctions = lost_auctions - won_auctions
    end
    render 'spree/api/auctions/index'
  end

  def show
    render 'spree/api/auctions/show'
  end

  def create
    if @auction.present?
      render nothing: true, status: :conflict
    else
      @auction = Spree::Auction.new
      save_auction
    end
  end

  def update
    save_auction
  end

  def destroy
    @auction.cancel!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def best_price
    @auction.ship_to_zip = params[:auction][:ship_to_zip] unless params[:auction][:ship_to_zip].blank?

    if params[:auction][:shipping_option].blank?
      params[:auction][:shipping_option] = Spree::ShippingOption::OPTION[:ups_ground]
    end

    lowest_bid = @auction.best_price(
      quantity: params[:auction][:quantity],
      selected_shipping: params[:auction][:shipping_option],
      all_shipping: true
    )

    fail 'Failed to get best price' if lowest_bid.nil?

    response = {
      best_price: lowest_bid.order.total.to_f,
      delivery_days: ((lowest_bid.delivery_date - Time.zone.now) / (60 * 60 * 24)).ceil,
      shipping_options: []
    }

    production_time = @auction.product.production_time
    production_time ||= 14

    lowest_bid.shipping_options.each do |option|
      adjusted_delivery_date = Time.zone.now + (2 + production_time + option.delivery_days).days
      response[:shipping_options].push(
        name: option.name,
        delta: option.delta,
        delivery_date: adjusted_delivery_date,
        delivery_days: option.delivery_days,
        shipping_option: option.shipping_option
      )
    end

    render json: response
  rescue StandardError => e
    Rails.logger.error("Failed to get best price: #{e}")
    render nothing: true, status: :internal_server_error
  end

  def reject_order
    @auction.order_rejected!
    params[:rejection_reason] = '' if params[:rejection_reason].blank?
    Resque.enqueue(
      RejectOrder,
      auction_id: params[:id],
      rejection_reason: params[:rejection_reason]
    )
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def resolve_dispute
    @auction.dispute_resolved!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def order_confirm
    winning_bid = @auction.winning_bid

    winning_bid.transaction do
      if @auction.preferred?(winning_bid.seller)
        amount = winning_bid.seller_fee.round(2) * 100
        description = "Auction ID: #{@auction.reference}, Seller: #{winning_bid.seller.email}"

        Stripe::Charge.create(
          amount: amount.to_i,
          currency: 'usd',
          source: params[:token],
          description: description
        )

        winning_bid.order.update_attributes(payment_state: 'completed')
        Spree::OrderUpdater.new(winning_bid.order).update
        if winning_bid.manage_workflow
          if @auction.clone_id.nil?
            @auction.confirm_order!
          else
            @auction.clone_confirm_order!
          end
        else
          @auction.invoice_paid!
          @auction.update_attributes(payment_claimed: true)
        end
      else
        if @auction.clone_id.nil?
          @auction.confirm_order!
        else
          @auction.clone_confirm_order!
        end
      end
    end
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def in_production
    @auction.in_production!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def claim_payment
    Resque.enqueue(
      ClaimPaymentRequest,
      auction_id: @auction.id,
      payment_type: params['payment_type'],
      bank_name: params['bank_name'],
      bank_branch: params['bank_branch'],
      bank_routing: params['bank_routing'],
      bank_acct_number: params['bank_acct_number']
    )
    @auction.update_attributes(payment_claimed: true)
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def tracking
    if params[:tracking_number].present?
      @auction.update_attributes(
        tracking_number: params[:tracking_number],
        shipping_agent: params[:agent_type]
      )
      @auction.enter_tracking!
      render json: { nothing: true, status: :ok, error_msg: '' }
    else
      render json: { nothing: true, status: :bad_request, error_msg: 'Tracking number is required.' }
    end
  rescue
    render json: { nothing: true, status: :internal_server_error }
  end

  def confirmed_delivery
    @auction.delivery_confirmed! if @auction.confirm_receipt? || @auction.send_for_delivery?

    if params[:status][:status] == 'submit'
      @review = Spree::Review.new(
        rating: params[:rating],
        auction_id: @auction.id,
        user_id: @auction.winning_bid.seller.id,
        review: params[:review],
        ip_address: request.remote_ip
      )
      if @review.save
        Resque.enqueue(ReviewRating, auction_id: @auction.id)
      else
        flash[:error] = @review.errors.first[1]
      end
    end
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def tracking_information
    response = @auction.ups_response.shipment_events
    render json: response
  rescue
    render nothing: true, status: :internal_server_error
  end

  def approve_proof
    @auction.approve_proof!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def reject_proof
    if params[:proof_feedback].present?
      @auction.update(proof_feedback: params[:proof_feedback])
      @auction.reject_proof!
      render json: { nothing: true, status: :ok, error_msg: '' }
    else
      render json: { nothing: true, status: :ok, error_msg: 'Your feedback is required.' }
    end
  rescue
    render json: { nothing: true, status: :internal_server_error }
  end

  private

  def fetch_auction
    @auction = Spree::Auction.find(params[:id])
  end

  def save_auction
    @json = JSON.parse(request.body.read)
    @auction.assign_attributes(@json)
    if @auction.save
      render 'spree/api/auctions/show'
    else
      render nothing: true, status: :bad_request
    end
  end

  def auction_params
    params.require(:auction).permit(
      :product_id,
      :buyer_id,
      :quantity,
      :description,
      :started,
      :filter,
      :only_preferred,
      :ended,
      :state,
      :page,
      :per_page,
      :lost,
      :rejection_reason
    )
  end
end
