class Spree::Api::AuctionsController < Spree::Api::BaseController
  before_action :fetch_auction, except: [:index, :create]

  def index
    if params[:buyer_id].present?
      @auctions = Spree::Auction.where(buyer_id: params[:buyer_id])
        .includes(:buyer, :bids, :product)
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    else
      @auctions = Spree::Auction.all
        .includes(:buyer, :bids, :product)
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
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
    @auction.destroy
    render nothing: true, status: :ok
  end

  private

  def auction_params
    params.require(:auction).permit(:product_id,
      :buyer_id,
      :quantity,
      :description,
      :started,
      :ended,
      :page,
      :per_page)
  end

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
end
