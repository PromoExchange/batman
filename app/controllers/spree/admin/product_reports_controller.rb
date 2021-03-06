class Spree::Admin::ProductReportsController < Spree::Admin::BaseController
  def index
    respond_to do |format|
      format.html do
        @products = Spree::Product.all
        @factories = Spree::Supplier.all
      end
      format.csv do
        render_csv
      end
    end
  end

  def render_csv
    filename = "product-gap-#{Time.zone.today}.csv"

    headers['Content-Type'] = 'text/csv'
    headers['Content-disposition'] = "attachment; filename=\"#{filename}\""
    headers['Content-Transfer-Encoding'] = 'binary'
    headers['Cache-Control'] ||= 'no-cache'
    headers.delete('Content-Length')

    response.status = 200

    self.response_body = csv_lines
  end

  def csv_lines
    Enumerator.new do |y|
      y << Spree::Product.csv_header.to_s
      Spree::Product.find_in_batches(params[:dc_acct_num]) { |product| y << product.to_csv_row.to_s }
    end
  end
end
