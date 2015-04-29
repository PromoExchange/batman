class ProductsController < BaseAPIController
  private
    def query_params
      params.permit(:product_id)
    end
end
