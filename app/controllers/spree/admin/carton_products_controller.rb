class Spree::Admin::CartonProductsController < Spree::Admin::BaseController
  before_action :load_product
  before_action :load_carton, only: [:edit, :update]

  def edit
    @carton = Spree::Carton.new if @carton.nil?
  end

  def update
    @carton.update_attributes(carton_product_params)
    flash[:success] = 'Carton updated'
    redirect_to edit_admin_product_url(@product)
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_carton
    @carton = Spree::Carton.find(params[:id])
  end

  def carton_product_params
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
