Spree::Api::V1::ProductsController.class_eval do
  def best_price
    @product = Spree::Product.find(params[:id])

    best_prices = @product.best_price(
      quantity: purchase_params[:quantity].to_i,
      shipping_option: Spree::ShippingOption::OPTION.keys[purchase_params[:shipping_option].to_i],
      shipping_address: purchase_params[:shipping_address].to_i
    )

    # There is no set way to extend a Spree API endpoint
    # The standard spree way would be to add a attribute array to
    # api_helpers_decorator, adding a rabl file and use respond_to below.
    # This works for now and is considerably simpler.
    render json: best_prices, status: :ok
  rescue StandardError => e
    Rails.logger.error("Failed to get best price: #{e}")
    render nothing: true, status: :internal_server_error
  end

  def purchase_params
    params.require(:purchase).permit(
      :product_id,
      :quantity,
      :shipping_address,
      :shipping_option
    )
  end
end
