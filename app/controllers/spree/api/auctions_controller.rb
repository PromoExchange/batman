class Spree::Api::AuctionsController < Spree::Api::BaseController
  before_action :fetch_auction, except: [:index, :create]

  def index
    params[:buyer_id] = {} if params[:buyer_id].blank?
    params[:seller_id] = {} if params[:seller_id].blank?
    params[:status] = 'open' if params[:status].blank?

    statuses = params[:status].split(',')

    @auctions = Spree::Auction.search(
      bids_seller_id_eq: params[:seller_id],
      buyer_id_eq: params[:buyer_id],
      status_in: statuses
    ).result

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
    @auction.update_attributes(status: 'cancelled', cancelled_date: Time.zone.now)
    render nothing: true, status: :ok
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
      :ended,
      :status,
      :page,
      :per_page
    )
  end
end
