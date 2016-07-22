Spree::Api::V1::ProductsController.class_eval do
  def best_price
    # TODO: Move this to the product model
    @product = find_product(params[:id])
    quantity = params[:quantity] || @product.minimum_quantity
    shipping_address = params[:shipping_address]
    shipping_option = params[:shipping_option]
    shipping_option ||= Spree::ShippingOption::OPTION[:ups_ground]

    # TODO: Move cache point to here
    quote = @product.quotes.where(
      quantity: quantity,
      main_color: @product.preconfigure.main_color,
      shipping_address: shipping_address.to_i,
      custom_pms_colors: @product.preconfigure.custom_pms_colors,
      selected_shipping_option: shipping_option.to_i
    ).first_or_create

    @best_prices = []
    @best_prices << {
      best_price: quote.total_price,
      delivery_days: ((quote.selected_shipping.delivery_date - Time.zone.now) / 1.day.to_i).ceil
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
