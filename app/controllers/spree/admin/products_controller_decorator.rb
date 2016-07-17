Spree::Admin::ProductsController.class_eval do
  create.before :set_custom

  private

  def set_custom
    @product.custom_product = true
  end
end
