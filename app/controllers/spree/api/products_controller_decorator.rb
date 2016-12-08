Spree::Api::ProductsController.class_eval do
  def best_price
    @product = Spree::Product.find(params[:id])

    best_price_params = {
      quantity: params[:quantity],
      shipping_option: params[:shipping_option],
      shipping_address: params[:shipping_address],
      configuration: params[:configuration]
    }

    best_price_params[:quantity] &&= best_price_params[:quantity].to_i
    best_price_params[:quantity] ||= @product.last_price_break_minimum

    best_price_params[:shipping_option] &&= best_price_params[:shipping_option].to_sym
    best_price_params[:shipping_option] ||= :ups_ground

    best_price_params[:shipping_address] ||= @product.company_store.buyer.shipping_address.id

    # Called from the website JS
    if params[:purchase].present?
      best_price_params = {
        quantity: params[:purchase][:quantity].to_i,
        shipping_option: (params[:purchase][:shipping_option].to_sym || :ups_ground),
        shipping_address: params[:purchase][:shipping_address].to_i
      }
    end

    if best_price_params[:configuration].present?
      configuration = Spree::Preconfigure.find(best_price_params[:configuration])
      best_price_params = best_price_parms.reverse_merge.configuration.best_price_params
    end

    # Best price for the supplied shipping option (the selected)
    requested_price = @product.best_price(best_price_params)

    response = {
      best_price: requested_price[:best_price].to_f,
      quantity: best_price_params[:quantity],
      delivery_days: requested_price[:delivery_days],
      shipping_options: []
    }

    @product.available_shipping_options.each do |soption|
      this_shipping_option = soption[0].to_sym
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
