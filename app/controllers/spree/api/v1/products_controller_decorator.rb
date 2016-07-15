Spree::Api::V1::ProductsController.class_eval do
  def best_price
    @product = find_product(params[:id])
    quantity = params[:quantity] || @product.minimum_quantity
    shipping_address = params[:shipping_address]
    shipping_option = params[:shipping_option]
    shipping_option ||= Spree::ShippingOption::OPTION[:ups_ground]

    # TODO: Move cache point to here
    quote = @product.quotes.where(
      quantity: quantity,
      main_color: preconfigure.main_color,
      shipping_address: shipping_address,
      imprint_method: preconfigure.imprint_method,
      custom_pms_colors: preconfigure.custom_pms_colors,
      selected_shipping_option: shipping_option
    ).first_or_create

    @best_prices = []
    @best_prices << {
      best_price: quote.total_price,
      delivery_days: ((quote.selected_shipping_option.delivery_date - Time.zone.now) / (60 * 60 * 24)).ceil
    }

    # There is no set way to extend a Spree API endpoint
    # The standard spree way would be to add a attribute array to
    # api_helpers_decorator, adding a rabl file and use respond_to below.
    # This works for now and is considerably simpler.
    render json: @best_prices, status: :ok
  rescue StandardError => e
    Rails.logger.error("Failed to get best price: #{e}")
    render nothing: true, status: :internal_server_error
  end
end
