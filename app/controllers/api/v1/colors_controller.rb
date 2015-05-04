module API
  module V1
    class ColorsController < API::BaseAPIController
      before_filter :find_color, only: [:show, :update]

      def index
        @colors = Color.all
        render json: @colors
      end

      def show
        render json: @colors
      end

      def create
        if @colors.present?
          render nothing: true, status: :conflict
        else
          @colors = Color.new
          @colors.assign_attributes(@json['color'])
          if @colors.save
            render json: @colors
          else
             render nothing: true, status: :bad_request
          end
        end
      end

      def update
        @colors.assign_attributes(@json['color'])
        if @colors.save
            render json: @colors
        else
            render nothing: true, status: :bad_request
        end
      end

    private

      def find_color
        @colors = Color.find(params[:id])
        render nothing: true, status: :not_found unless @colors.present?
      end
    end
  end
end
