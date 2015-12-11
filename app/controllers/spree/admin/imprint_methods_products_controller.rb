class Spree::Admin::ImprintMethodsProductsController < Spree::Admin::BaseController
  prepend_before_action :load_product
  before_action :load_imprint_methods, only: [:edit, :new]
  before_action :load_imprint_methods_product, only: [:edit, :update, :destroy]

  def index
    @imprint_methods_products = Spree::ImprintMethodsProduct.where(product: @product)
  end

  def new
    @imprint_methods_product = Spree::ImprintMethodsProduct.new
  end

  def create
    Spree::ImprintMethodsProduct.create(imprint_methods_product_params)
    redirect_to action: :index
  end

  def update
    @imprint_methods_product.update_attributes(imprint_methods_product_params)
    redirect_to action: :index
  end

  def destroy
    @imprint_methods_product.destroy
    flash[:success] = flash_message_for(@imprint_methods_product, :successfully_removed)
    redirect_to action: :index
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_imprint_methods
    @imprint_methods = Spree::ImprintMethod.all
  end

  def load_imprint_methods_product
    @imprint_methods_product = Spree::ImprintMethodsProduct.find(params[:id])
  end

  def imprint_methods_product_params
    params.require(:imprint_methods_product).permit(:imprint_method_id, :product_id)
  end
end
