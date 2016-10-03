class Spree::Admin::MarkupsController < Spree::Admin::ResourceController
  belongs_to 'spree/company_store', find_by: :id
  before_action :setup_markup, only: :index

  private

  def load_data
    @suppliers = Spree::Supplier.where(company_store: false).order(:name)
    super
  end

  def setup_markup
    @company_store.markups.build
  end
end
