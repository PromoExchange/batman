class Spree::AuctionsController < Spree::StoreController
  before_action :store_location
  before_action :require_login, only: [:new, :edit, :show, :auction_payment]
  before_action :fetch_auction, except: [:index, :create, :new, :auction_payment]

  def index
    if params[:buyer_id].present?
      @auctions = Spree::Auction.where(buyer_id: params[:buyer_id])
        .includes(:bids, :product)
        .where.not(status: 'cancelled')
    else
      @auctions = Spree::Auction.where.not(status: 'cancelled').includes(:product)
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

    supporting_data
  end

  def create
    auction_data = params[:auction]

    @auction = Spree::Auction.new(
      product_id: auction_data[:product_id],
      buyer_id: auction_data[:buyer_id],
      quantity: auction_data[:quantity],
      imprint_method_id: auction_data[:imprint_method_id],
      main_color_id: auction_data[:main_color_id],
      shipping_address_id: auction_data[:shipping_address_id],
      payment_method: auction_data[:payment_method],
      logo_id: auction_data[:logo_id],
      custom_pms_colors: auction_data[:custom_pms_colors],
      started: Time.zone.now
    )
    @auction.pms_color_match = true unless auction_data[:custom_pms_colors].blank?

    unless params[:auction][:pms_colors].nil?
      params[:auction][:pms_colors].split(',').each do |pms_color|
        @auction.pms_colors << Spree::PmsColor.find(pms_color)
      end
    end
    @auction.save!

    @request_idea_id = auction_data[:request_idea] if auction_data[:request_idea].present?
    idea = Spree::RequestIdea.where(id: @request_idea_id).take
    idea.update_attributes(auction_id: @auction.id) if idea

    send_prebid_request @auction.id

    unless auction_data[:invited_sellers].nil?
      auction_data[:invited_sellers].split(';').each do |seller_email|
        next if seller_email.blank?

        email_type = :is
        invited_seller = Spree::User.where(email: seller_email).first

        if invited_seller.nil?
          email_type = :non
        else
          Spree::AuctionsUser.create(
            auction_id: @auction.id,
            user_id: invited_seller.id
          )
        end

        Resque.enqueue(
          SellerInvite,
          auction_id: @auction.id,
          type: email_type,
          email_address: seller_email
        )
      end
    end

    redirect_to '/dashboards', flash: { notice: 'Auction was created successfully.' }
  rescue
    supporting_data
    render :new
  end

  def send_prebid_request(auction_id)
    embroidery_imprint_method_id = Spree::ImprintMethod.where(name: 'Embroidery').first.id
    return if embroidery_imprint_method_id == params[:auction][:imprint_method_id].to_i
    Resque.enqueue(CreatePrebids, auction_id: auction_id)
  end

  def destroy
    @auction.update_attributes(status: 'cancelled', cancelled_date: Time.zone.now)
    redirect_to dashboards_path, flash: { notice: 'Auction was cancelled successfully.' }
  end

  def auction_payment
    @bid = Spree::Bid.find(params[:bid_id])
  end

  def upload_proof
    if params[:proof_file].blank?
      redirect_to :back, flash: { error: 'Document is required.' }
    elsif @auction.update_attributes(proof_file: params[:proof_file], proof_feedback: '')
      @auction.upload_proof!
      redirect_to "/invoices/#{@auction.id}", flash: { notice: 'Your document uploaded successfully.' }
    else
      redirect_to :back, flash: { error: @auction.errors.full_messages.join(' and also ') }
    end
  rescue
    redirect_to :back, flash: { error: 'Unable to upload your document.' }
  end

  def download_proof
    send_data open(@auction.proof_file.url).read,
      filename: @auction.proof_file_file_name,
      disposition: 'attachment'
  end

  private

  def fetch_auction
    @auction = Spree::Auction.find(params[:id])
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def supporting_data
    @addresses = []
    @auction.buyer.addresses.active.each do |address|
      add = true
      add = false if address.bill?
      add = true if address.ship?

      next unless add

      @addresses << [
        "#{address}",
        address.id]
    end

    @product_properties = @auction.product.product_properties.accessible_by(current_ability, :read)

    # TODO: Only send colors that this product can use
    @pms_colors = Spree::PmsColorsSupplier
      .where(supplier_id: @auction.product.supplier)
      .joins(:pms_color)
      .order(:imprint_method_id)
      .pluck(
        :pms_color_id,
        :display_name,
        :hex,
        :pantone,
        :name,
        :imprint_method_id
      )

    @main_colors = Spree::ColorProduct
      .where(product_id: @auction.product.id)
      .pluck(:color, :product_id)

    @imprint_methods = Spree::ImprintMethodsProduct
      .joins(:imprint_method)
      .where(product_id: @auction.product.id)
      .pluck(:name, :imprint_method_id)

    @user = spree_current_user

    @logo = Spree::Logo.new

    @pxaddress = Spree::Pxaddress.new
  end

  def auction_params
    params.require(:auction).permit(
      :auction_id,
      :product_id,
      :buyer_id,
      :logo_id,
      :started,
      :pms_colors,
      :custom_pms_colors,
      :quantity,
      :imprint_method_id,
      :main_color_id,
      :shipping_address_id,
      :payment_method,
      :ended,
      :invited_sellers
    )
  end
end
