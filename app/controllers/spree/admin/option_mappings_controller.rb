class Spree::Admin::OptionMappingsController < Spree::Admin::ResourceController
  before_action :load_option_mapping, only: [:edit, :update]

  respond_to :html

  def index
    respond_with(@collection)
  end

  def create
    Spree::OptionMapping.create(option_mapping_params)
    redirect_to admin_option_mappings_path
  end

  def load_option_mapping
    @imprint_method = Spree::OptionMapping.find(params[:id])
  end

  private

  def option_mapping_params
    params.require(:option_mapping).permit(
      :dc_acct_num,
      :dc_name,
      :px_name,
      :do_not_save
    )
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
end
