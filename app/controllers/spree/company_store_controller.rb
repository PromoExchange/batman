class Spree::CompanyStoreController < Spree::StoreController
  layout "company_store_layout"
  before_action :fetch_company_store, only: [:show]

  private

  def fetch_company_store
    @company_store = Spree::CompanyStore.where(slug: params[:id]).first
    @products = Spree::Product.where(supplier: @company_store.supplier).order(:id)
  end

  def company_store_params
    params.require(:company_store).permit(:id)
  end
end
