class Spree::AuctionsController < Spree::StoreController
  before_action :require_login, only: [:new, :edit]
  before_action :fetch_auction, except: [:index, :create, :new, :accept_bid]

  def index
    if params[:buyer_id].present?
      @auctions = Spree::Auction.where(buyer_id: params[:buyer_id])
        .includes(:bids, :product)
        .where.not(status: 'cancelled')
    else
      @auctions = Spree::Auction.where.not(status: 'cancelled').includes(:bids, :product)
    end
  end

  def show
    @product_properties = @auction.product.product_properties
  end

  def accept_bid
    auction = Spree::Auction.find(params[:auction_id])
    auction.update_attributes(status: 'closed')
    redirect_to dashboards_path
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

    @product_properties = @auction.product.product_properties.accessible_by(current_ability, :read)

    # TODO: pluck it
    @pms_colors = Spree::PmsColorsSupplier
      .select(
        'pms_color_id,
        display_name,
        spree_pms_colors.hex,
        spree_pms_colors.pantone,
        spree_pms_colors.name')
      .joins(:pms_color)
      .where(supplier_id: @auction.product.supplier)

    @main_colors = Spree::ColorProduct
      .where(product_id: @auction.product.id)
      .pluck(:color, :product_id)

    @imprint_methods = Spree::ImprintMethodsProduct
      .joins(:imprint_method)
      .where(product_id: @auction.product.id)
      .pluck(:name, :imprint_method_id)
  end

  def create
    # TODO: Come back and clean this
    @auction = Spree::Auction.create(
      product_id: params[:auction][:product_id],
      buyer_id: params[:auction][:buyer_id],
      started: params[:auction][:started],
      quantity: params[:auction][:quantity],
      shipping_address: params[:auction][:shipping_address],
      imprint_method_id: params[:auction][:imprint_method_id],
      main_color_id: params[:auction][:main_color_id],
      shipping_address_id: params[:auction][:shipping_address_id],
      payment_method: params[:auction][:payment_method],
      ended: params[:auction][:ended]
    )

    unless params[:auction][:pms_colors].nil?
      params[:auction][:pms_colors].split(',').each do |pms_color|
        Spree::AuctionPmsColor.create(
          auction_id: @auction.id,
          pms_color_id: pms_color
        )
      end
    end

    redirect_to(products_path, notice: 'Auction was successfully created.')
  rescue
    redirect_to(products_path, flash: { error: 'Failed to create an auction' })
  end

  def destroy
    @auction.update_attributes(status: 'cancelled', cancelled_date: Time.zone.now)
    redirect_to dashboards_path
  end

  private

  def auction_params
    params.require(:auction).permit(
      :auction_id,
      :product_id,
      :buyer_id,
      :started,
      :pms_colors,
      :quantity,
      :shipping_address,
      :imprint_method_id,
      :main_color_id,
      :shipping_address_id,
      :payment_method,
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
