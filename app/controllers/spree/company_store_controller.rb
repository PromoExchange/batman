class Spree::CompanyStoreController < Spree::StoreController
  before_action :fetch_company_store, only: [:show]

  def show
  end

  private

  def fetch_company_store
    @company_store = Spree::CompanyStore.where(slug: params[:id]).first
  end

  def company_store_params
    params.require(:company_store).permit(:id)
  end
end
