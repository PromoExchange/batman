class Spree::Api::TaxratesController < Spree::Api::BaseController
  def update
    tax_rate = Spree::TaxRate.find(params[:id])
    tax_rate.update_attributes(taxrates_params)
    render nothing: true, status: :ok
  end

  private

  def taxrates_params
    params.require(:taxrate).permit(:amount, :include_in_sandh)
  end
end
