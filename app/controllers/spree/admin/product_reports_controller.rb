class Spree::Admin::ProductReportsController < Spree::Admin::BaseController
  def index
    respond_to do |format|
      format.html { @products = Spree::Product.all }
      format.csv do
        send_data Spree::Product.to_csv, filename: "product-#{Time.zone.today}.csv"
      end
    end
  end
  private
end
