class Spree::CompanyStoreController < Spree::StoreController
  layout "company_store_layout"
  before_action :fetch_company_store, only: [:show]

  def show
  end

  private

  def fetch_company_store
    @company_store = Spree::CompanyStore.where(slug: params[:id]).first
    @products = Spree::Product.where(supplier: @company_store.supplier)
  end

  def company_store_params
    params.require(:company_store).permit(:id)
  end
end
