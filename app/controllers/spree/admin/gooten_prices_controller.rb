class Spree::Admin::GootenPricesController < Spree::Admin::ResourceController
  before_action :load_product
  before_action :load_special_price, only: [:edit, :update]

  def model_class
    Spree::Gooten::Price
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_special_price
    @special_price = Spree::Gooten::Price.find(params[:id])
  end

  def location_after_save
    edit_admin_product_path(@product)
  end

  def gooten_price_params
    params.require(:gooten_price).permit(
      :quantity,
      :price
    )
  end
end
