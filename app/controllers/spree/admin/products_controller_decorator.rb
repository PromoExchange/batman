Spree::Admin::ProductsController.class_eval do
  create.before :set_custom
  after_action :preconfigure, only: :create

  def load
    redirect_to action: :edit
  end

  protected

  def preconfigure
    user = Spree::CompanyStore.find_by(supplier: params[:product][:supplier_id]).buyer
    @product.preconfigure = Spree::Preconfigure.new(
      buyer: user,
      imprint_method: @product.imprint_method,
      main_color: @product.color_product.first,
      logo: user.logos.where(custom: true).first
    )
  end

  def load_data
    @taxons = Spree::Taxon.order(:name)
    @option_types = Spree::OptionType.order(:name)
    @tax_categories = Spree::TaxCategory.order(:name)
    @shipping_categories = Spree::ShippingCategory.order(:name)
    @suppliers = Spree::Supplier.order(:name)
  end

  private

  def set_custom
    @product.custom_product = true
  end
end
