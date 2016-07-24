Spree::Api::V1::ProductsController.class_eval do
  def best_price
    @product = find_product(params[:id])
    binding.pry
    best_prices = @product.best_price

    # There is no set way to extend a Spree API endpoint
    # The standard spree way would be to add a attribute array to
    # api_helpers_decorator, adding a rabl file and use respond_to below.
    # This works for now and is considerably simpler.
    render json: best_prices, status: :ok
  rescue StandardError => e
    Rails.logger.error("Failed to get best price: #{e}")
    render nothing: true, status: :internal_server_error
  end
end
