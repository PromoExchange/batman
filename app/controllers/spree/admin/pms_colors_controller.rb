class Spree::Admin::PmsColorsController < Spree::Admin::ResourceController
  before_action :load_pms_color, only: [:edit, :update]

  def index
    respond_to do |format|
      format.html { respond_with(@collection) }
      format.csv do
        @pms_colors = Spree::PmsColor.all
        send_data @pms_colors.to_csv, filename: "pms_color-#{Time.zone.today}.csv"
      end
    end
  end

  def create
    Spree::PmsColor.create(pms_color_params)
    redirect_to admin_pms_colors_path
  end

  def update
    @pms_color.update_attributes(pms_color_params)
    unless pms_color_params[:display_name].blank?
      Spree::PmsColorsSupplier.where(
        pms_color_id: params[:id]
      ).update_all(display_name: pms_color_params[:display_name])
    end
    redirect_to admin_pms_colors_path
  end

  def load_pms_color
    @pms_color = Spree::PmsColor.find(params[:id])
  end

  private

  def collection
    return @collection if @collection.present?
    params[:q] = {} if params[:q].blank?

    @collection = super
    @search = @collection.ransack(params[:q])
    @collection = @search.result
      .page(params[:page])
      .per(Spree::Config[:properties_per_page])

    @collection
  end

  def pms_color_params
    params.require(:pms_color).permit(
      :name,
      :display_name,
      :pantone,
      :hex
    )
  end
end
