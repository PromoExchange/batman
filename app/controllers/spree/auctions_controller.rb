class Spree::AuctionsController < Spree::StoreController
  before_action :require_login, only: [:new, :edit]
  before_action :fetch_auction, except: [:index, :create, :new]

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
  end

  def new
    @auction = Spree::Auction.new(product_id: params[:product_id],
                                    buyer_id: current_spree_user.id,
                                    started: Time.zone.now)
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

  private

  def auction_params
    params.require(:auction).permit(:product_id,
      :buyer_id,
      :auction,
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
      render 'spree/auctions/show'
    else
      render nothing: true, status: :bad_request
    end
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end
end
