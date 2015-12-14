class Spree::Admin::UpchargeTypesController < Spree::Admin::ResourceController
  before_action :load_upcharge_type, only: [:edit, :update]

  respond_to :html

  def index
    respond_with(@collection)
  end

  def create
    Spree::UpchargeType.create(upcharge_type_params)
    redirect_to admin_upcharge_types_path
  end

  private

  def load_upcharge_type
    @upcharge_type = Spree::UpchargeType.find(params[:id])
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

  def upcharge_type_params
    params.require(:upcharge_type).permit(:name)
  end
end
