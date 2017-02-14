class Spree::PurchasesController < Spree::StoreController
  layout 'company_store_layout'

  def new
    quality = params[:purchase][:quality] || :economy
    @category = Spree::Taxon.find_by_id(params[:purchase][:category_id])
    @product = Spree::Product.find_by_id(purchase_params[:product_id]) ||
      @current_company_store.products(category: @category.to_sym, quality: quality.to_sym).first

    supporting_data

    @purchase = Spree::Purchase.new(
      buyer: @current_company_store.buyer,
      custom_pms_colors: @product.preconfigure.custom_pms_colors,
      imprint_method_id: @product.preconfigure.imprint_method_id,
      logo: @current_company_store.default_logo,
      main_color_id: @product.preconfigure.main_color_id,
      price_breaks: [],
      product_id: purchase_params[:product_id].to_i,
      quality_option: quality,
      quantity: nil,
      shipping_option: :ups_ground,
      sizes: []
    )

    if @current_company_store.traditional?
      @product.price_breaks.each do |price_break|
        lowest_range = price_break.split('..')[0].gsub(/\D/, '').to_i
        best_price = @product.best_price(quantity: lowest_range)[:best_price].to_f / lowest_range
        @purchase.price_breaks << [lowest_range, best_price]
      end
    end

    render :new
  rescue StandardError => e
    Rails.logger.error(e)
    render nothing: true, status: 500
  end

  def create
    # TODO: Move :size into purchase_params
    if params[:size].present?
      params[:purchase][:quantity_sizes] = params[:size].to_json
      params[:size] = params[:size].merge(params[:size]) { |_k, val| val.to_i < 0 ? 0 : val.to_i }
      @size_quantity = params[:size]
      params[:purchase][:quantity] = params[:size].values.map(&:to_i).reduce(:+)
      @total_size = purchase_params[:quantity]
    end

    @total_size ||= purchase_params[:quantity]

    Rails.logger.info("Product ID: #{purchase_params[:product_id]}")
    Rails.logger.info("Buyer ID: #{purchase_params[:buyer_id]}")
    Rails.logger.info("Quantity: #{purchase_params[:quantity]}")
    Rails.logger.info("imprint_method_id: #{purchase_params[:imprint_method_id]}")
    Rails.logger.info("main_color_id: #{purchase_params[:main_color_id]}")
    Rails.logger.info("ship_to_zip: #{purchase_params[:ship_to_zip]}")
    Rails.logger.info("logo_id: #{purchase_params[:logo_id]}")
    Rails.logger.info("custom_pms_colors: #{purchase_params[:custom_pms_colors]}")
    Rails.logger.info("address_id: #{purchase_params[:address_id]}")
    Rails.logger.info("shipping_option: #{purchase_params[:shipping_option]}")
    Rails.logger.info("quantity_sizes: #{purchase_params[:quantity_sizes] || '(not wearable)'}")

    @product = Spree::Product.find(purchase_params[:product_id])

    # TODO: Move this logic into a/ purchase model OR b/ product
    best_price = @product.best_price(
      quantity: purchase_params[:quantity].to_i,
      shipping_option: purchase_params[:shipping_option].to_sym,
      shipping_address: purchase_params[:address_id]
    )

    order = nil

    Spree::Purchase.transaction do
      new_purchase_params = purchase_params.except(:address, :image_id)
      purchase = Spree::Purchase.new(new_purchase_params)

      if purchase_params[:image_id].present?
        purchase.image = Spree::Image.new(attachment: Spree::Image.find(purchase_params[:image_id]).attachment)
      end

      order = Spree::Order.create(
        user_id: purchase_params[:buyer_id],
        ship_address_id: purchase_params[:address_id]
      )

      purchase.order_id = order.id

      # TODO: Once the quote structure gets recast as a calculator we can have a real quantity here.
      li = Spree::LineItem.create(
        currency: 'USD',
        order_id: order.id,
        quantity: 1,
        variant: @product.master
      )

      li.price = best_price[:best_price].to_f
      li.save!

      Spree::OrderUpdater.new(order).update

      purchase.save!
    end
    redirect_to "/accept/#{order.id}"
  rescue StandardError => e
    Rails.logger.error("Failed to create purchase #{e}")
    supporting_data
    render :new, flash: { error: 'There was an error creating purchase' }
  end

  def purchase_payment
    @order = Spree::Order.find(params[:order_id])
  end

  def csaccept
    @order = Spree::Order.find(params[:order_id])

    Rails.logger.info("Stripe Charge: #{(@order.total.to_f * 100).to_i}, "\
      "token: #{params[:stripeToken]} description: #{params[:stripeEmail]}")

    Stripe::Charge.create(
      amount: (@order.item_total.to_f * 100).to_i,
      currency: 'usd',
      source: params[:stripeToken],
      description: params[:stripeEmail].to_s
    )

    Resque.enqueue(SendInvoice, order_id: @order.id, payment_email: params[:stripeEmail])

    message = "<!channel> Order (#{@order.purchase.reference}) for $#{@order.item_total} by #{@order.user.email}"
    message << " via #{params[:stripeEmail]}" unless params[:stripeEmail].blank?
    message << " : #{@order.purchase.image.attachment.url}" if @order.purchase.image.present?

    SLACK.ping message

    redirect_to "/company_store/#{current_company_store.slug}"
  rescue StandardError => e
    Rails.logger.error(e)
    render nothing: true, status: 500
  end

  def supporting_data
    @product_properties = @product.product_properties.accessible_by(current_ability, :read)

    @addresses = []
    # TODO: Nope, change this
    @current_company_store.buyer.addresses.map do |a|
      address = OpenStruct.new
      address.zipcode = a.zipcode
      address.name = a.to_s
      address.id = a.id
      @addresses << address
    end

    @states = Spree::State.where(country: Spree::Country.find_by(iso: 'US'))

    @shipping_options = [
      ['UPS Ground', :ups_ground],
      ['UPS Three-Day Select', :ups_3day_select],
      ['UPS Second Day Air', :ups_second_day_air],
      ['UPS Next Day Air Saver', :ups_next_day_air_saver],
      ['UPS Next Day Air Early A.M.', :ups_next_day_air_early_am],
      ['UPS Next Day Air', :ups_next_day_air]
    ]

    if @category
      @quality_options = []
      [:economy, :premium, :super_premium].each do |quality|
        product = @current_company_store.products(category: @category.to_sym, quality: quality).first
        raise "Unable to find product that matches category: #{@category.to_sym} - quality: #{quality}" if product.nil?
        quality_option = {
          name: quality == :super_premium ? product.original_supplier.name : quality.to_s.titleize,
          quality: quality,
          product_id: product.id,
          quality_note: product.quality_note,
          images: []
        }

        product.images.each do |image|
          quality_option[:images] << {
            large_src: image.attachment.url(:large),
            small_src: image.attachment.url(:small),
            alt: image.attachment.name,
            id: image.id
          }
        end

        @quality_options << quality_option
      end
    end
  end

  def purchase_params
    params.require(:purchase).permit(
      :product_id,
      :image_id,
      :buyer_id,
      :logo_id,
      :ship_to_zip,
      :quantity,
      :imprint_method_id,
      :main_color_id,
      :address_id,
      :shipping_option,
      :quality_option,
      :quantity_sizes,
      address: [:company, :address1, :address2, :city, :state_id, :zipcode]
    )
  end
end
