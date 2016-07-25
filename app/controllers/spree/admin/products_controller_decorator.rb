Spree::Admin::ProductsController.class_eval do
  create.before :set_custom

  protected

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
