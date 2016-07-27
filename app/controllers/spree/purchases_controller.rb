class Spree::PurchasesController < Spree::StoreController
  layout 'company_store_layout'

  def new
    @product = Spree::Product.find(purchase_params[:id])
    @purchase = {
      quantity: nil,
      product_id: params[:id],
      logo_id: product.company_store.buyer.logos.first.id,
      custom_pms_colors: product.preconfigure.custom_pms_colors,
      imprint_method_id: product.preconfigure.imprint_method_id,
      main_color_id: product.preconfigure.main_color_id,
      buyer_id: product.company_store.buyer.id,
      price_breaks: [],
      sizes: []
    }

    product.price_breaks.each do |price_break|
      lowest_range = price_break[0].split('..')[0].gsub(/\D/, '').to_i
      @purchase.price_breaks << [lowest_range, product.best_price(quantity: lowest_range)]
    end

    supporting_data

    render :new
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

    @shipping_options = [
      ['UPS Ground', Spree::ShippingOption::OPTION[:ups_ground]],
      ['UPS Three-Day Select', Spree::ShippingOption::OPTION[:ups_3day_select]],
      ['UPS Second Day Air', Spree::ShippingOption::OPTION[:ups_second_day_air]],
      ['UPS Next Day Air Saver', Spree::ShippingOption::OPTION[:ups_next_day_air_saver]],
      ['UPS Next Day Air Early A.M.', Spree::ShippingOption::OPTION[:ups_next_day_air_early_am]],
      ['UPS Next Day Air', Spree::ShippingOption::OPTION[:ups_next_day_air]]
    ]
  end

  def purchase_params
    params.require(:purchase).permit(
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
