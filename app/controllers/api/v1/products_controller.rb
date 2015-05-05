module API
  module V1
    class ProductsController < API::BaseAPIController
      before_filter :find_product, only: [:show, :update]

      def index
        @products = Product.all
        render json: @products
      end

      def show
        render json: @products
      end

      def create
        if @product.present?
          render nothing: true, status: :conflict
        else
          @products = Product.new
          @products.assign_attributes(@json['product'])
          if @products.save
            render json: @products
          else
             render nothing: true, status: :bad_request
          end
        end
      end

      def update
        @products.assign_attributes(@json['product'])
        if @products.save
            render json: @products
        else
            render nothing: true, status: :bad_request
        end
      end

      private

      def find_product
        @products = Product.find(params[:id])
        render nothing: true, status: :not_found unless @products.present?
      end
    end
  end
end
