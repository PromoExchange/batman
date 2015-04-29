class API::V1::ProductsController < API::BaseAPIController
  private
    def query_params
      params.permit(:product_id)
    end
end
