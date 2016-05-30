class Spree::Admin::ImprintMethodsController < Spree::Admin::ResourceController
  before_action :load_imprint_method, only: [:edit, :update]

  respond_to :html

  def index
    respond_with(@collection)
  end

  def create
    Spree::ImprintMethod.create(imprint_method_params)
    redirect_to admin_imprint_methods_path
  end

  private

  def load_imprint_method
    @imprint_method = Spree::ImprintMethod.find(params[:id])
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

  def imprint_method_params
    params.require(:imprint_method).permit(:name)
  end
end
