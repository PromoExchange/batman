class Spree::Api::AuctionsController < Spree::Api::BaseController
  before_action :fetch_auction, except: [:index, :create]

  def index
    params[:buyer_id] = {} if params[:buyer_id].blank?
    params[:seller_id] = {} if params[:seller_id].blank?
    params[:state] = 'open' if params[:state].blank?

    states = params[:state].split(',')

    if params[:lost].nil?
      @auctions = Spree::Auction.search(
        bids_seller_id_eq: params[:seller_id],
        buyer_id_eq: params[:buyer_id],
        state_in: states
      ).result
    else
      @auctions = Spree::Auction.search(
        bids_seller_id_eq: params[:seller_id],
        bids_state_eq: 'lost'
      ).result
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
    @auction.update_attributes(state: 'cancelled', cancelled_date: Time.zone.now)
    render nothing: true, status: :ok
  end

  def order_confirm
    @auction.confirm_order!
    Resque.enqueue_at(
      Time.zone.now + 15.days,
      TrackingReminder,
      auction_id: @auction.id
    )
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

  def tracking
    if params[:tracking_number].present?
      @auction.update_attributes(tracking_number: params[:tracking_number])
      @auction.enter_tracking!
      render json: { nothing: true, status: :ok, error_msg: '' }
    else
      render json: { nothing: true, status: :ok, error_msg: 'Tracking number is required.' }
    end
  rescue
    render json: { nothing: true, status: :internal_server_error }
  end

  def confirmed_delivery
    @auction.delivery_confirmed!
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
      :lost
    )
  end
end
