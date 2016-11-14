Spree::Api::ProductsController.class_eval do
  def best_price
    @product = Spree::Product.find(params[:id])

    # Best price for the supplied shipping option (the selected)
    requested_price = @product.best_price(
      quantity: purchase_params[:quantity].to_i,
      shipping_option: (purchase_params[:shipping_option].to_sym || :ups_ground),
      shipping_address: purchase_params[:shipping_address].to_i
    )

    response = {
      best_price: requested_price[:best_price].to_f,
      quantity: purchase_params[:quantity].to_i,
      delivery_days: requested_price[:delivery_days],
      shipping_options: []
    }

    @product.available_shipping_options.each do |soption|
      this_shipping_option = soption[0].to_sym
      alternate_price = @product.best_price(
        quantity: purchase_params[:quantity].to_i,
        shipping_option: this_shipping_option,
        shipping_address: purchase_params[:shipping_address].to_i
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

  def purchase_params
    params.require(:purchase).permit(
      :product_id,
      :quantity,
      :shipping_address,
      :shipping_option
    )
  end
end
