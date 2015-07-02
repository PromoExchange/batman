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
    @auction = Spree::Auction.new(
      product_id: params[:product_id],
      buyer_id: current_spree_user.id,
      started: Time.zone.now)

    @addresses = []
    @addresses << [
      "Shipping: #{@auction.buyer.shipping_address}",
      @auction.buyer.shipping_address.id] unless @auction.buyer.shipping_address.nil?

    @addresses << [
      "Billing: #{@auction.buyer.billing_address}",
      @auction.buyer.billing_address.id] unless @auction.buyer.billing_address.nil?

    # TODO: There must be a cleaner way of doing this
    @pms_colors = Spree::PmsColorsSupplier
      .select('pms_color_id,display_name,spree_pms_colors.hex,spree_pms_colors.pantone,spree_pms_colors.name')
      .joins(:pms_color)
      .where(supplier_id: @auction.product.supplier)
  end

  def create
    @auction = Spree::Auction.new(auction_params)
    respond_to do |format|
      if @auction.save
        format.html do
          redirect_to(products_path, notice: 'Auction was successfully created.')
        end
      else
        format.html do
          redirect_to(products_path, fatal: 'Auction was not created successfully')
        end
      end
    end
  end

  private

  def auction_params
    params.require(:auction).permit(
      :product_id,
      :buyer_id,
      :started,
      :pms_colors,
      :quantity,
      :shipping_address,
      :ended,
      :page,
      :per_page)
  end

  def fetch_auction
    @auction = Spree::Auction.find(params[:id])
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end
end
