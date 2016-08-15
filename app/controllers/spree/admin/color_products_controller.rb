class Spree::Admin::ColorProductsController < Spree::Admin::ResourceController
  before_action :load_product
  before_action :load_color_product, only: [:edit, :update, :destroy]
  before_action :load_color_products, only: [:index]
  after_action :set_preconfigure, only: [:create, :update]
  after_action :set_validity, only: [:create, :update, :destroy]

  private

  def set_preconfigure
    @product.preconfigure.update_attribute(:main_color, @product.color_product.first)
  end

  def set_validity
    @product.loading!
    @product.check_validity!
    @product.loaded! if @product.state == 'loading'
  end

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_color_product
    @color_product = Spree::ColorProduct.find(params[:id])
  end

  def load_color_products
    @color_products = Spree::ColorProduct.where(product: @product)
  end

  def location_after_save
    admin_product_color_products_url(@product)
  end

  def color_product_params
    params.require(:color_product).permit(:color, :product_id)
  end
end
