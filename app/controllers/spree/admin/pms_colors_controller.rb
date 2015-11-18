class Spree::Admin::PmsColorsController < Spree::Admin::BaseController
  before_action :load_pms_color, only: [:edit, :update]

  respond_to :html

  def index
    @pms_colors = Spree::PmsColor.all
  end

  def new
    @pms_color = Spree::PmsColor.new
  end

  def create
    Spree::PmsColor.create(pms_color_params)
    redirect_to admin_pms_colors_path
  end

  def load_order
    @pms_color = Spree::PmsColor.find(params[:id])
  end

  private

  def pms_color_params
    params.require(:pms_color).permit(
      :name,
      :pantone,
      :hex
    )
  end
end
