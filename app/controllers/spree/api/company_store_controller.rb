class Spree::Api::CompanyStoreController < Spree::Api::BaseController
  before_action :fetch_company_store, except: [:index]

  def index
    @company_stores = Spree::CompanyStore.all
    render 'spree/api/company_store/index'
  end

  def show
    render 'spree/api/company_store/show'
  end

  private

  def fetch_company_store
    @company_store = Spree::CompanyStore.find(params[:id])
  end
end
