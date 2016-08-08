class Spree::Admin::PreconfigureProductsController < Spree::Admin::BaseController
  prepend_before_action :load_product
  before_action :load_preconfigure, only: [:destroy, :show, :update]

  def create
    Spree::Preconfigure.create(preconfigure_params)
    redirect_to action: :show
  end

  def destroy
    @preconfigure.destroy!
  end

  def show
    @preconfigure = Spree::Preconfigure.find(params[:preconfigure_id])
  end

  def update
    @preconfigure.update_attributes(preconfigure_params)
    redirect_to action: :show
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def preconfigure_params
    params.require(:preconfigure_product).permit(
      :product_id,
      :buyer_id,
      :logo_id,
      :main_color_id,
      :imprint_method_id
    )
  end
end
