Spree::Admin::ProductsController.class_eval do
  create.before :set_custom
  after_action :preconfigure, only: [:create, :update]
  before_action :price_breaks, only: [:edit]

  protected

  def preconfigure
    return if params[:product][:supplier_id].blank?
    user = Spree::CompanyStore.find_by(supplier: params[:product][:supplier_id]).buyer
    @product.preconfigure = Spree::Preconfigure.where(
      buyer: user,
      imprint_method: @product.imprint_method,
      main_color: @product.color_product.first,
      logo: user.logos.where(custom: true).first,
      product: @product
    ).first_or_create
    @product.save!
  rescue StandardError => e
    Rails.logger.error "Unable to create preconfigure: #{e}"
  end

  def price_breaks
    @price_breaks = []
    @product.price_breaks.each do |price_break|
      lowest_range = price_break.split('..')[0].gsub(/\D/, '').to_i
      best_price = @product.best_price(quantity: lowest_range, need_workbook: true)
      @price_breaks << [lowest_range, best_price[:best_price].to_f / lowest_range, best_price[:workbook]]
    end
  rescue StandardError => e
    Rails.logger.error "Unable to create price_breaks: #{e}"
  end

  def load_data
    @taxons = Spree::Taxon.order(:name)
    @option_types = Spree::OptionType.order(:name)
    @tax_categories = Spree::TaxCategory.order(:name)
    @shipping_categories = Spree::ShippingCategory.order(:name)
    @suppliers = Spree::Supplier.where(company_store: false).order(:name)
    @company_stores = Spree::Supplier.where(company_store: true).order(:name)
  end

  private

  def set_custom
    @product.custom_product = true
  end
end
