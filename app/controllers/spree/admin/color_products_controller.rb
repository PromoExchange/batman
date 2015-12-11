class Spree::Admin::ColorProductsController < Spree::Admin::BaseController
  before_action :load_product
  before_action :load_color_product, only: [:edit, :update, :destroy]
  after_action :set_validity, only: [:create, :update, :destroy]

  def index
    @color_products = Spree::ColorProduct.where(product: @product)
  end

  def new
    @color_product = Spree::ColorProduct.new
  end

  def create
    Spree::ColorProduct.create(color_product_params)
    redirect_to action: :index
  end

  def update
    @color_product.update_attributes(color_product_params)
    redirect_to action: :index
  end

  def destroy
    @color_product.destroy
    flash[:success] = flash_message_for(@color_product, :successfully_removed)
    redirect_to action: :index
  end

  private

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

  def color_product_params
    params.require(:color_product).permit(:color, :product_id)
  end
end
