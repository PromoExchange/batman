class Spree::PurchasesController < Spree::StoreController
  layout 'company_store_layout'

  def new
    # TODO: Allow creation with shipping_option
    @product = Spree::Product.find(purchase_params[:product_id])

    @purchase = Spree::Purchase.new(
      quantity: nil,
      product_id: purchase_params[:product_id].to_i,
      logo_id: @product.company_store.buyer.logos.first.id,
      custom_pms_colors: @product.preconfigure.custom_pms_colors,
      imprint_method_id: @product.preconfigure.imprint_method_id,
      main_color_id: @product.preconfigure.main_color_id,
      buyer_id: @product.company_store.buyer.id,
      price_breaks: [],
      sizes: [],
      shipping_option: Spree::ShippingOption::OPTION[:ups_ground]
    )

    @product.price_breaks.each do |price_break|
      lowest_range = price_break.split('..')[0].gsub(/\D/, '').to_i
      best_price = @product.best_price(quantity: lowest_range)[:best_price].to_f / lowest_range
      @purchase.price_breaks << [lowest_range, best_price]
    end

    supporting_data

    render :new
  rescue StandardError => e
    Rails.logger.error(e)
    render nothing: true, status: 500
  end

  def create
    if params[:size].present?
      params[:size] = params[:size].merge(params[:size]) { |_k, val| (val.to_i < 0) ? 0 : val.to_i }
      @size_quantity = params[:size]
      purchase_params[:quantity] = params[:size].values.map(&:to_i).reduce(:+)
      @total_size = purchase_params[:quantity]
    end

    Rails.logger.info("Product ID: #{purchase_params[:product_id]}")
    Rails.logger.info("Buyer ID: #{purchase_params[:buyer_id]}")
    Rails.logger.info("Quantity: #{purchase_params[:quantity]}")
    Rails.logger.info("imprint_method_id: #{purchase_params[:imprint_method_id]}")
    Rails.logger.info("main_color_id: #{purchase_params[:main_color_id]}")
    Rails.logger.info("ship_to_zip: #{purchase_params[:ship_to_zip]}")
    Rails.logger.info("logo_id: #{purchase_params[:logo_id]}")
    Rails.logger.info("custom_pms_colors: #{purchase_params[:custom_pms_colors]}")

    order = Spree::Order.create(user_id: purchase_params[:buyer_id])

    # TODO: Factory method to get quote object
    product = Spree::Product.find(purchase_params[:product_id])

    # TODO: Get from form selection (currently ship_to_zip)
    best_price = product.best_price(
      quantity: purchase_params[:quantity].to_i,
      shipping_option: Spree::ShippingOption::OPTION.keys[purchase_params[:shipping_option].to_i],
      shipping_address: product.company_store.buyer.shipping_address.id
    )

    # TODO: Once the quote structure gets recast as a
    # as calculator we can have a real quantity here.

    li = Spree::LineItem.create(
      currency: 'USD',
      order_id: order.id,
      quantity: 1,
      variant: product.master
    )

    li.price = best_price[:best_price].to_f
    li.save!

    Spree::OrderUpdater.new(order).update

    redirect_to "/accept/#{order.id}"
  rescue StandardError => e
    Rails.logger.error("Failed to create auction #{e}")
    supporting_data
    render :new, flash: { error: 'There was an error creating purchase' }
  end

  def purchase_payment
    @order = Spree::Order.find(params[:order_id])
  end

  def csaccept
    @order = Spree::Order.find(params[:order_id])

    Stripe::Charge.create(
      amount: (@order.total.to_f * 100).to_i,
      currency: 'usd',
      source: params[:stripeToken],
      description: params[:stripeEmail].to_s
    )

    redirect_to '/'
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

    @shipping_options = [
      ['UPS Ground', Spree::ShippingOption::OPTION[:ups_ground]],
      ['UPS Three-Day Select', Spree::ShippingOption::OPTION[:ups_3day_select]],
      ['UPS Second Day Air', Spree::ShippingOption::OPTION[:ups_second_day_air]],
      ['UPS Next Day Air Saver', Spree::ShippingOption::OPTION[:ups_next_day_air_saver]],
      ['UPS Next Day Air Early A.M.', Spree::ShippingOption::OPTION[:ups_next_day_air_early_am]],
      ['UPS Next Day Air', Spree::ShippingOption::OPTION[:ups_next_day_air]]
    ]
  end

  def create_related_data(auction_data)
  end

  def purchase_params
    params.require(:purchase).permit(
      :product_id,
      :buyer_id,
      :logo_id,
      :started,
      :pms_colors,
      :custom_pms_colors,
      :ship_to_zip,
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
