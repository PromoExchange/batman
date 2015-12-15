class Spree::Admin::UpchargeProductsController < Spree::Admin::BaseController
  prepend_before_action :load_product
  before_action :load_imprint_methods, only: [:edit, :new]
  before_action :load_upcharge_types, only: [:edit, :new]
  before_action :load_upcharge, only: [:edit, :update, :destroy]

  def index
    @upcharges = Spree::UpchargeProduct.where(product: @product)
  end

  def new
    @upcharge = Spree::UpchargeProduct.new
  end

  def create
    Spree::UpchargeProduct.create(upcharge_params)
    redirect_to action: :index
  end

  def update
    @upcharge.update_attributes(upcharge_params)
    redirect_to action: :index
  end

  def destroy
    @upcharge.destroy
    flash[:success] = flash_message_for(@upcharge, :successfully_removed)
    redirect_to action: :index
  end

  private

  def load_product
    @product = Spree::Product.friendly.find(params[:product_id])
  end

  def load_upcharge
    @upcharge = Spree::UpchargeProduct.find(params[:id])
  end

  def load_upcharge_types
    @upcharge_types = Spree::UpchargeType.all
  end

  def load_imprint_methods
    @imprint_methods = Spree::ImprintMethod.all
  end

  def upcharge_params
    params.require(:upcharge_product).permit(
      :upcharge_type_id,
      :related_id,
      :value,
      :range,
      :price_code,
      :imprint_method_id
    )
  end
end
