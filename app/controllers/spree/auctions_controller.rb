class Spree::AuctionsController < Spree::StoreController
  before_action :store_location
  before_action :require_login, only: [:edit, :show]
  before_action :fetch_auction, except: [:index, :create, :new, :auction_payment, :csaccept]

  layout :get_layout

  def get_layout
    @auction.clone.present? ? 'company_store_layout' : 'spree/layouts/spree_application'
  end

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
    if session[:pending_auction_id].present?
      # TODO: Do we need to call require_buyer in non CS mode?
      # require_buyer
      @auction = Spree::Auction.find_by(id: session[:pending_auction_id])
      @cloned_pms_colors = @auction.pms_colors.pluck(:id).map(&:inspect).join(',')
    else
      if params[:clone_auction_id].present?
        clone_me = Spree::Auction.find(params[:clone_auction_id])
        @auction = clone_me.dup
        @auction.quantity = nil
        @auction.clone = clone_me
        @auction.logo = clone_me.logo
        @cloned_pms_colors = clone_me.pms_colors.pluck(:id).map(&:inspect).join(',')
        @price_breaks = []
        @auction.product.price_caches.order(:position).pluck(:range, :lowest_price).each do |price|
          lowest_range = price[0].split('..')[0].gsub(/\D/, '').to_i
          @price_breaks << [lowest_range, price[1].to_f / lowest_range]
        end
      end
    end
    if @auction.nil?
      @auction = Spree::Auction.new(
        product_id: params[:product_id],
        started: Time.zone.now
      )
    end

    supporting_data
    estimated_ship
  end

  def create
    auction_data = params[:auction]

    if params[:size].present?
      params[:size] = params[:size].merge(params[:size]) { |_k, val| (val.to_i < 0) ? 0 : val.to_i }
      @size_quantity = params[:size]
      auction_data[:quantity] = params[:size].values.map(&:to_i).reduce(:+)
      @total_size = auction_data[:quantity]
    end

    Rails.logger.info("Product ID: #{auction_data[:product_id]}")
    Rails.logger.info("Buyer ID: #{auction_data[:buyer_id]}")
    Rails.logger.info("Quantity: #{auction_data[:quantity]}")
    Rails.logger.info("imprint_method_id: #{auction_data[:imprint_method_id]}")
    Rails.logger.info("main_color_id: #{auction_data[:main_color_id]}")
    Rails.logger.info("ship_to_zip: #{auction_data[:ship_to_zip]}")
    Rails.logger.info("logo_id: #{auction_data[:logo_id]}")
    Rails.logger.info("custom_pms_colors: #{auction_data[:custom_pms_colors]}")
    Rails.logger.info("clone_id: #{auction_data[:clone_id]}")

    @auction = Spree::Auction.new(
      product_id: auction_data[:product_id],
      buyer_id: auction_data[:buyer_id],
      quantity: auction_data[:quantity],
      imprint_method_id: auction_data[:imprint_method_id],
      main_color_id: auction_data[:main_color_id],
      ship_to_zip: auction_data[:ship_to_zip],
      logo_id: auction_data[:logo_id],
      custom_pms_colors: auction_data[:custom_pms_colors],
      started: Time.zone.now,
      clone_id: auction_data[:clone_id]
    )
    @auction.pms_color_match = true unless auction_data[:custom_pms_colors].blank?

    unless params[:auction][:pms_colors].nil?
      params[:auction][:pms_colors].split(',').each do |pms_color|
        @auction.pms_colors << Spree::PmsColor.find(pms_color)
      end
    end

    if @auction.clone_id.present?
      @auction.buyer = @current_company_store.buyer
      @auction.shipping_address = Spree::Address.find(params[:auction][:address_id].to_i)
      if @auction.shipping_address.nil?
        @auction.shipping_address = @current_company_store.buyer.shipping_address
      end
    end

    @auction.save!

    if @auction.clone_id.nil?
      unless current_spree_user
        @auction.pending
        session[:pending_auction_id] = @auction.id
        redirect_to login_url and return
      end
    end

    create_related_data(auction_data)

    if auction_data[:clone_id].present?
      # Get the prebids NOW
      prebids = Spree::Prebid.where(supplier: @auction.product.original_supplier)
      prebids.each do |p|
        Rails.logger.info "Prebid Job: requesting bid creation: #{p.id}"
        p.create_prebid(@auction.id, params[:shipping_option])
      end

      # Find the lowest bid (first one)
      bid = @auction.bids.first

      if bid.nil?
        redirect_to '/', flash: { notice: 'Unable to calculate price, please contact support' }
      end

      @auction.pending_accept

      redirect_to "/accept/#{bid.id}"
    else
      redirect_to '/dashboards', flash: { notice: 'Auction was created successfully.' }
    end
  rescue
    supporting_data
    estimated_ship
    @cloned_pms_colors = @auction.pms_colors.map(&:id)
    render :new
  end

  def update
    @auction = Spree::Auction.find(params[:id])

    auction_data = params[:auction]

    if params[:size].present?
      params[:size] = params[:size].merge(params[:size]) { |_k, val| (val.to_i < 0) ? 0 : val.to_i }
      @size_quantity = params[:size]
      auction_data[:quantity] = params[:size].values.map(&:to_i).reduce(:+)
      @total_size = auction_data[:quantity]
    end

    @auction.update_attributes(
      product_id: auction_data[:product_id],
      buyer_id: auction_data[:buyer_id],
      quantity: auction_data[:quantity],
      imprint_method_id: auction_data[:imprint_method_id],
      main_color_id: auction_data[:main_color_id],
      ship_to_zip: auction_data[:ship_to_zip],
      logo_id: auction_data[:logo_id],
      custom_pms_colors: auction_data[:custom_pms_colors],
      started: Time.zone.now,
      state: 'open'
    )
    @auction.pms_color_match = true unless auction_data[:custom_pms_colors].blank?

    unless params[:auction][:pms_colors].nil?
      params[:auction][:pms_colors].split(',').each do |pms_color|
        @auction.pms_colors << Spree::PmsColor.find(pms_color)
      end
    end

    @auction.save!
    session.delete(:pending_auction_id)
    create_related_data(auction_data)

    redirect_to '/dashboards', flash: { notice: 'Auction was created successfully.' }
  rescue
    supporting_data
    estimated_ship
    render :new
  end

  def send_prebid_request(auction_id)
    return if ENV['DISABLE_PREBIDS'] == 'true'
    Resque.enqueue(CreatePrebids, auction_id: auction_id)
  end

  def destroy
    @auction.update_attributes(status: 'cancelled', cancelled_date: Time.zone.now)
    redirect_to dashboards_path, flash: { notice: 'Auction was cancelled successfully.' }
  end

  def csaccept
    @bid = Spree::Bid.find(params[:bid_id])

    Stripe::Charge.create(
      amount: (@bid.order.total.to_f * 100).to_i,
      currency: 'usd',
      source: params[:stripeToken],
      description: "#{params[:stripeEmail]}"
    )

    @bid.non_preferred_accept
    @bid.auction.accept

    redirect_to '/'
  end

  def auction_payment
    @bid = Spree::Bid.find(params[:bid_id])
    @auction = @bid.auction

    return unless @auction.clone_id.nil?

    customers = current_spree_user.customers
    @customers = customers.web_check.verified.concat customers.credit_card

    @addresses = current_spree_user.addresses.active.map do |address|
      next if address.bill? && !address.ship?
      ["#{address}", address.id]
    end

    @pxaddress = Spree::Pxaddress.new
    estimated_ship
  end

  def upload_proof
    if params[:proof_file].blank?
      render nothing: true, status: :unprocessable_entity, json: 'This is not a supported file format'
    elsif @auction.update_attributes(proof_file: params[:proof_file], proof_feedback: '')
      @auction.upload_proof!
      flash[:notice] = 'Your document uploaded successfully.'
      render js: "window.location = '/invoices/#{@auction.id}'"
    else
      render nothing: true, status: :unprocessable_entity, json: 'This is not a supported file format'
    end
  rescue
    render nothing: true, status: :unprocessable_entity, json: 'Unable to upload your document.'
  end

  def download_proof
    send_data open(@auction.proof_file.url).read,
      filename: @auction.proof_file_file_name,
      disposition: 'attachment'
  end

  private

  def fetch_auction
    @auction = Spree::Auction.find(params[:id])
    estimated_ship
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def require_buyer
    redirect_to root_path unless current_spree_user && current_spree_user.has_spree_role?(:buyer)
  end

  def estimated_ship
    @estimated_ship_date = 21.days.from_now
    return if @auction.nil?
    # HACK: Hack for Cabelas product
    @estimated_ship_date = 7.weeks.from_now if @auction.product.master.sku == 'Yeti-20'
  end

  def supporting_data
    @product_properties = @auction.product.product_properties.accessible_by(current_ability, :read)

    @pms_colors = Spree::PmsColorsSupplier
      .where(supplier_id: @auction.product.supplier)
      .joins(:pms_color)
      .order(:imprint_method_id)
      .pluck(
        :pms_color_id,
        :display_name,
        :hex,
        :name,
        :imprint_method_id
      )

    @main_colors = Spree::ColorProduct
      .where(product_id: @auction.product.id)
      .pluck(:color, :id)

    @imprint_methods = Spree::ImprintMethodsProduct
      .joins(:imprint_method)
      .where(product_id: @auction.product.id)
      .pluck(:name, :imprint_method_id)

    @user = spree_current_user

    @logo = Spree::Logo.new

    @pxaddress = Spree::Pxaddress.new

    return unless @current_company_store.present?
    @addresses = []
    @current_company_store.buyer.addresses.map do |a|
      address = OpenStruct.new
      address.zipcode = a.zipcode
      address.name = a.to_s
      address.id = a.id
      @addresses << address
    end

    @shipping_options = [
      ['UPS Ground', Spree::Prebid::SHIPPING_OPTION[:ups_ground]],
      ['UPS Three-Day Select', Spree::Prebid::SHIPPING_OPTION[:ups_3day_select]],
      ['UPS Second Day Air', Spree::Prebid::SHIPPING_OPTION[:ups_second_day_air]],
      ['UPS Next Day Air Saver', Spree::Prebid::SHIPPING_OPTION[:ups_next_day_air_saver]],
      ['UPS Next Day Air Early A.M.', Spree::Prebid::SHIPPING_OPTION[:ups_next_day_air_early_am]],
      ['UPS Next Day Air', Spree::Prebid::SHIPPING_OPTION[:ups_next_day_air]]
    ]
  end

  def create_related_data(auction_data)
    if @auction.is_wearable?
      Spree::AuctionSize.create(
        auction_id: @auction.id,
        product_size: params[:size]
      )
    end

    @request_idea_id = auction_data[:request_idea] if auction_data[:request_idea].present?
    idea = Spree::RequestIdea.where(id: @request_idea_id).take
    idea.update_attributes(auction_id: @auction.id) if idea

    send_prebid_request @auction.id if @auction.clone_id.nil?

    return if auction_data[:invited_sellers].nil?

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

  def auction_params
    params.require(:auction).permit(
      :auction_id,
      :clone_auction_id,
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
