class Spree::GootenPurchasesController < Spree::StoreController
  layout 'company_store_layout'
  before_action :store_view_setup

  def new
    @category = Spree::Taxon.find(purchase_params[:category_id])
    quality = purchase_params[:quality] || :economy
    @product = @current_company_store.products(category: @category.to_sym, quality: quality.to_sym).first

    supporting_data

    @purchase = Spree::Purchase.new(
      quantity: nil,
      product_id: @product.id,
      logo: @current_company_store.default_logo,
      imprint_method_id: @product.preconfigure.imprint_method_id,
      main_color_id: @product.preconfigure.main_color_id,
      buyer_id: @current_company_store.buyer.id,
      price_breaks: [],
      sizes: [],
      shipping_option: :ups_ground,
      quality_option: @quality_options.find { |qo| qo[:quality] == quality.to_sym }[:quality]
    )

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

    @states = Spree::State.where(country: Spree::Country.find_by(iso: 'US'))

    @shipping_options = [
      ['UPS Ground', :ups_ground],
      ['UPS Three-Day Select', :ups_3day_select],
      ['UPS Second Day Air', :ups_second_day_air],
      ['UPS Next Day Air Saver', :ups_next_day_air_saver],
      ['UPS Next Day Air Early A.M.', :ups_next_day_air_early_am],
      ['UPS Next Day Air', :ups_next_day_air]
    ]

    economy_product = @current_company_store.products(category: @category.to_sym, quality: :economy).first
    premium_product = @current_company_store.products(category: @category.to_sym, quality: :premium).first
    super_premium_product = @current_company_store.products(category: @category.to_sym, quality: :super_premium).first

    @quality_options = [
      { name: 'Economy', quality: :economy, product_id: economy_product.id },
      { name: 'Premium', quality: :premium, product_id: premium_product.id },
      {
        name: super_premium_product.original_supplier.name,
        quality: :super_premium,
        product_id: super_premium_product.id
      }
    ]
  end

  def purchase_params
    params.require(:purchase).permit(
      :category_id,
      :product_id,
      :buyer_id,
      :logo_id,
      :ship_to_zip,
      :quantity,
      :imprint_method_id,
      :main_color_id,
      :address_id,
      :shipping_option,
      :quality,
      address: [:company, :address1, :address2, :city, :state_id, :zipcode]
    )
  end
end
