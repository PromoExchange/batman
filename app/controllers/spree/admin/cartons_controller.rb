class Spree::Admin::CartonsController < Spree::Admin::ResourceController
  before_action :load_product
  before_action :load_carton, only: [:edit, :update]

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_carton
    @carton = Spree::Carton.find(params[:id])
  end

  def location_after_save
    edit_admin_product_path(@product)
  end

  def carton_params
    params.require(:carton).permit(
      :product_id,
      :width,
      :length,
      :height,
      :weight,
      :quantity,
      :originating_zip,
      :fixed_price
    )
  end
end
