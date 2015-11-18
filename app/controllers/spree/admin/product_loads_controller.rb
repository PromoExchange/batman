class Spree::Admin::ProductLoadsController < Spree::Admin::BaseController
  def index
    @num_database = Spree::Product.count
    @num_states = Spree::Product.group(:state).count
    @num_product_queue = Resque.size(:product_load)
    @num_factory_queue = Resque.size(:product_load_factory)
    @num_factories = Spree::Supplier.count
    @loaded_factories = Spree::Product.joins(:supplier)
      .group('spree_suppliers.name', :state)
      .order('spree_suppliers.name')
      .count
    @dc_suppliers = Spree::DcSupplier.supplier_list
  end

  def create
    Resque.enqueue(
      ProductLoadFactory,
      name: params[:factory_name],
      dc_acct_num: params[:dc_acct_num]
    )
    redirect_to spree.admin_product_loads_path, flash: { notice: 'Factory load in queue' }
  rescue
    redirect_to spree.admin_product_loads_path, flash: { error: 'Failed to queue factory load' }
  end

  def destroy_factory
    supplier_id = Spree::Supplier.where(name: params[:factory_name]).first
    Spree::Product.where(supplier_id: supplier_id).destroy_all
    Spree::Supplier.where(name: params[:factory_name]).destroy_all
    redirect_to spree.admin_product_loads_path
  rescue
    redirect_to spree.admin_product_loads_path
  end

  private

  def product_load_params
    params.require(:product_load).permit(
      :factory_name,
      :dc_acct_num
    )
  end
end
