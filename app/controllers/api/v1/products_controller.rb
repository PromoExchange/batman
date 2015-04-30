module API
  module V1
    class ProductsController < API::BaseController
      private

      def query_params
        params.permit(:product_id)
      end
    end
  end
end
