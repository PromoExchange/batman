module API
  module V1
    class MaterialsController < API::BaseAPIController
      # TODO: DRY this for all API
      before_filter :find_material, only: [:show, :update]

      def index
        @materials = Material.all
        render json: @materials
      end

      def show
        render json: @materials
      end

      def create
        if @materials.present?
          render nothing: true, status: :conflict
        else
          @materials = Material.new
          @materials.assign_attributes(@json['color'])
          if @materials.save
            render json: @materials
          else
             render nothing: true, status: :bad_request
          end
        end
      end

      def update
        @materials.assign_attributes(@json['color'])
        if @materials.save
            render json: @materials
        else
            render nothing: true, status: :bad_request
        end
      end

    private

      def find_color
        @materials = Material.find(params[:id])
        render nothing: true, status: :not_found unless @materials.present?
      end
    end
  end
end
