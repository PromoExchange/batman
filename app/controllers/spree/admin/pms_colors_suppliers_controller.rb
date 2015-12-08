class Spree::Admin::PmsColorsSuppliersController < Spree::Admin::ResourceController
  before_action :load_pms_colors_supplier, only: [:edit, :update]

  def index
    respond_with(@collection)
  end

  def create
    Spree::PmsColorsSupplier.create(pms_colors_supplier_params)
    redirect_to admin_pms_colors_suppliers_path
  end

  def update
    @pms_colors_supplier.update_attributes(pms_colors_supplier_params)
    redirect_to admin_pms_colors_suppliers_path
  end

  private

  def load_pms_colors_supplier
    @pms_colors_supplier = Spree::PmsColorsSupplier.find(params[:id])
  end

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

  def pms_colors_supplier_params
    params.require(:pms_colors_supplier).permit(
      :pms_color_id,
      :supplier_id,
      :display_name,
      :imprint_method_id
    )
  end
end
