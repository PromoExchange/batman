class Spree::Admin::SuppliersController < Spree::Admin::ResourceController
  before_action :load_supplier, only: [:edit, :update, :addresses]

  respond_to :html

  def index
    respond_with(@collection)
  end

  def create
    Spree::Supplier.create(supplier_params)
    redirect_to admin_suppliers_path
  end

  def addresses
    return unless request.put?
    if @supplier.update_attributes(supplier_params)
      flash.now[:success] = 'Address updated'
    end
    redirect_to admin_suppliers_path
  end

  def load_supplier
    @supplier = Spree::Supplier.find(params[:supplier_id]) unless params[:supplier_id].nil?
  end

  private

  def supplier_params
    params.require(:supplier).permit([:name, :dc_acct_num] | [
      ship_address_attributes: permitted_address_attributes,
      bill_address_attributes: permitted_address_attributes
    ])
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
