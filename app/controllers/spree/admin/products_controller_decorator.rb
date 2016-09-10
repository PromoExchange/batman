Spree::Admin::ProductsController.class_eval do
  create.before :set_custom
  after_action :preconfigure, only: [:create, :update]

  def load
    Resque.enqueue(CompanyStoreProductPrebid, company_store: @product.company_store.slug, id: @product.id)
    redirect_to action: :edit
  end

  protected

  def preconfigure
    return if params[:product][:supplier_id].blank?
    user = Spree::CompanyStore.find_by(supplier: params[:product][:supplier_id]).buyer
    @product.preconfigure = Spree::Preconfigure.where(
      buyer: user,
      imprint_method: @product.imprint_method,
      main_color: @product.color_product.first,
      logo: user.logos.where(custom: true).first
    ).first_or_create
    @product.save!
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
