class Spree::Admin::PmsColorsController < Spree::Admin::ResourceController
  before_action :load_pms_color, only: [:edit, :update]

  respond_to :html

  def index
    respond_with(@collection)
    # @pms_colors = Spree::PmsColor.all
  end

  def create
    Spree::PmsColor.create(pms_color_params)
    redirect_to admin_pms_colors_path
  end

  def load_pms_color
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

  def collection
    return @collection if @collection.present?
    # params[:q] can be blank upon pagination
    params[:q] = {} if params[:q].blank?

    @collection = super
    @search = @collection.ransack(params[:q])
    @collection = @search.result
      .page(params[:page])
      .per(Spree::Config[:properties_per_page])

    @collection
  end
end
