class Spree::Api::TestersController < Spree::Api::BaseController
  def memory_load
    @tax_rates = Spree::TaxRate.where(user: 10).order(:name)
    render nothing: true, status: :ok
  end
end
