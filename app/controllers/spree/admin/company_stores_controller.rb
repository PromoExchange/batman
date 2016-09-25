class Spree::Admin::CompanyStoresController < Spree::Admin::ResourceController
  before_action :load_company_store, only: [:edit, :update]
  before_action :load_data, only: [:edit, :new]
  helper_method :clone_object_url

  def clone
    @new = @company_store.duplicate

    if @new.save
      flash[:success] = Spree.t('notice_messages.company_store_cloned')
    else
      flash[:error] = Spree.t('notice_messages.company_store_not_cloned')
    end

    redirect_to edit_admin_company_store_url(@new)
  end

  private

  def collection
    return @collection if @collection.present?
    params[:q] ||= {}
    params[:q][:deleted_at_null] ||= '1'

    params[:q][:s] ||= 'name asc'
    @collection = super
    # Don't delete params[:q][:deleted_at_null] here because it is used in view to check the
    # checkbox for 'q[deleted_at_null]'. This also messed with pagination when deleted_at_null is checked.
    if params[:q][:deleted_at_null] == '0'
      @collection = @collection.with_deleted
    end
    # @search needs to be defined as this is passed to search_form_for
    # Temporarily remove params[:q][:deleted_at_null] from params[:q] to ransack products.
    # This is to include all products and not just deleted products.
    @search = @collection.ransack(params[:q].reject { |k, _v| k.to_s == 'deleted_at_null' })
    @collection = @search.result
      .page(params[:page])
      .per(params[:per_page] || Spree::Config[:admin_products_per_page])
    @collection
  end

  def clone_object_url(resource)
    clone_admin_company_store_url resource
  end

  def load_company_store
    @company_store = Spree::CompanyStore.find(params[:id])
  end

  def load_data
    @users = Spree::User.joins(:spree_roles).where(spree_roles: { name: 'buyer' })
    @suppliers = Spree::Supplier.where(company_store: true)
  end

  def permitted_resource_params
    params.require(:company_store).permit(
      :buyer_id,
      :display_name,
      :host,
      :logo,
      :name,
      :slug,
      :supplier_id,
      markups_attributes: [:eqp, :id, :markup, :live, :supplier_id]
    )
  end
end
