Spree::Api::ProductsController.class_eval do
  def best_price
    @product = Spree::Product.find(params[:id])

    best_price_params = {}
    purchase_params = params[:purchase]

    best_price_params[:quantity] = (purchase_params && purchase_params.key?(:quantity)) && purchase_params[:quantity].to_i
    best_price_params[:quantity] ||= params[:quantity] && params[:quantity].to_i
    best_price_params[:quantity] ||= @product.minimum_quantity

    best_price_params[:shipping_option] = (purchase_params && purchase_params.key?(:shipping_option)) && purchase_params[:shipping_option].to_sym
    best_price_params[:shipping_option] ||= params[:shipping_option] && params[:shipping_option].to_sym
    best_price_params[:shipping_option] ||= :ups_ground

    best_price_params[:shipping_address] = (purchase_params && purchase_params.key?(:shipping_address)) && purchase_params[:shipping_address].to_i
    best_price_params[:shipping_address] ||= params[:shipping_address] && params[:shipping_address].to_i
    best_price_params[:shipping_address] ||= @product.company_store.buyer.shipping_address.id

    if best_price_params[:configuration].present?
      configuration = Spree::Preconfigure.find(best_price_params[:configuration])
      best_price_params = best_price_parms.reverse_merge.configuration.best_price_params
    end

    requested_price = @product.best_price(best_price_params)

    response = {
      best_price: requested_price[:best_price].to_f,
      quantity: best_price_params[:quantity],
      delivery_days: requested_price[:delivery_days],
      shipping_options: []
    }

    @product.available_shipping_options.each do |soption|
      this_shipping_option = soption.to_sym
      alternate_price = @product.best_price(
        quantity: best_price_params[:quantity],
        shipping_option: this_shipping_option,
        shipping_address: best_price_params[:shipping_address]
      )

      shipping_name = this_shipping_option.to_s.titleize.sub('Ups', 'UPS')
      shipping_name = 'Fixed Price' if [:fixed_price_per_item, :fixed_price_total].include?(this_shipping_option)

      adjusted_delivery_date = Time.zone.now + (2 + alternate_price[:delivery_days]).days

      response[:shipping_options].push(
        name: shipping_name,
        total_cost: alternate_price[:best_price].to_f,
        delta: (alternate_price[:best_price] - requested_price[:best_price]).round(2).to_f,
        delivery_date: adjusted_delivery_date,
        delivery_days: alternate_price[:delivery_days],
        shipping_option: this_shipping_option
      )
    end

    render json: response, status: :ok
  rescue StandardError => e
    Rails.logger.error("Failed to get best price: #{e}")
    render nothing: true, status: :internal_server_error
  end

  def configure
    render json: Spree::Preconfigure.first
  end
end
