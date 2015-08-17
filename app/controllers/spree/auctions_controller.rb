class Spree::AuctionsController < Spree::StoreController
  before_action :require_login, only: [:new, :edit]
  before_action :fetch_auction, except: [:index, :create, :new]

  def index
    if params[:buyer_id].present?
      @auctions = Spree::Auction.where(buyer_id: params[:buyer_id])
        .includes(:bids, :product)
        .where.not(status: 'cancelled')
    else
      @auctions = Spree::Auction.where.not(status: 'cancelled').includes(:bids, :product)
    end
  end

  def pay_invoice
    auction = Spree::Auction.find(params[:auction_id])
    auction.update_attributes(status: 'completed')
    Resque.remove_delayed_selection { |args| args[0]['auction_id'] == auction.id }
    redirect_to dashboards_path
  end

  def new
    @auction = Spree::Auction.new(
      product_id: params[:product_id],
      buyer_id: current_spree_user.id,
      started: Time.zone.now)

    @addresses = []
    @addresses << [
      "#{@auction.buyer.shipping_address}",
      @auction.buyer.shipping_address.id] unless @auction.buyer.shipping_address.nil?

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

    @user = spree_current_user
  end

  def create
    auction_data = params[:auction]
    @auction = Spree::Auction.create(
      product_id: auction_data[:product_id],
      buyer_id: auction_data[:buyer_id],
      quantity: auction_data[:quantity],
      imprint_method_id: auction_data[:imprint_method_id],
      main_color_id: auction_data[:main_color_id],
      shipping_address_id: auction_data[:shipping_address_id],
      payment_method: auction_data[:payment_method],
      logo_id: auction_data[:logo_id]
    )

    unless params[:auction][:pms_colors].nil?
      params[:auction][:pms_colors].split(',').each do |pms_color|
        Spree::AuctionPmsColor.create(
          auction_id: @auction.id,
          pms_color_id: pms_color
        )
      end
    end
    send_prebid_request @auction.id

    redirect_to '/dashboards', flash: { notice: 'Auction was created successfully.' }
  rescue
    redirect_to '/dashboards', flash: { error: 'Failed to create an auction' }
  end

  def send_prebid_request(auction_id)
    embroidery_imprint_method_id = Spree::ImprintMethod.where(name: 'Embroidery').first.id
    return if embroidery_imprint_method_id == params[:auction][:imprint_method_id].to_i
    # Used for debuging, i.e. Direct call
    # CreatePrebids.perform(auction_id)
    Resque.enqueue(CreatePrebids, auction_id: auction_id)
  end

  def destroy
    @auction.update_attributes(status: 'cancelled', cancelled_date: Time.zone.now)
    redirect_to dashboards_path, flash: { notice: 'Auction was cancelled successfully.' }
  end

  private

  def fetch_auction
    @auction = Spree::Auction.find(params[:id])
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def auction_params
    params.require(:auction).permit(
      :auction_id,
      :product_id,
      :buyer_id,
      :started,
      :pms_colors,
      :quantity,
      :imprint_method_id,
      :main_color_id,
      :shipping_address_id,
      :payment_method,
      :ended,
      :page,
      :per_page
    )
  end
end
