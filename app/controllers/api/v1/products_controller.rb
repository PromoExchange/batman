class Api::V1::ProductsController < BaseController
  private
    def query_params
      params.permit(:product_id)
    end
end
