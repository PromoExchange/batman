# https://codelation.com/blog/rails-restful-api-just-add-water
module API
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :resource_instance, only: [:destroy, :show, :update]
    respond_to :json

    # POST /api/{plural_resource_name}
    def create
      resource_instance = resource_class.new(resource_params)

      if resource_instance.save
        render :show, status: :created
      else
        render json: resource_instance.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/{plural_resource_name}/1
    def destroy
      resource_instance.destroy
      head :no_content
    end

    # GET /api/{plural_resource_name}
    def index
      plural_resource_name = "@#{resource_name.pluralize}"
      Rails.logger.debug "Plural Resource Name: @#{plural_resource_name}"

      resources = resource_class.where(query_params)
      # .page(page_params[:page])
      # .per(page_params[:page_size])

      instance_variable_set(plural_resource_name, resources)
      respond_with instance_variable_get(plural_resource_name)
    end

    # GET /api/{plural_resource_name}/1
    def show
      respond_with resource_instance
    end

    # PATCH/PUT /api/{plural_resource_name}/1
    def update
      if resource_instance.update(resource_params)
        render :show
      else
        render json: resource_instance.errors, status: :unprocessable_entity
      end
    end

    private

    # Returns the resource from the created instance variable
    # @return [Object]
    def resource_instance
      instance_variable_get("@#{resource_name}")
    end

    # Use callbacks to share common setup or constraints between actions.
    def resource_instance=(resource = nil)
      resource ||= resource_class.find(params[:id])
      instance_variable_set("@#{resource_name}", resource)
    end

    # Returns the allowed parameters for searching
    # Override this method in each API controller
    # to permit additional parameters to search on
    # @return [Hash]
    def query_params
      {}
    end

    # Returns the allowed parameters for pagination
    # @return [Hash]
    # def page_params
    #   params.permit(:page, :page_size)
    # end

    # The resource class based on the controller
    # @return [Class]
    def resource_class
      @resource_class ||= resource_name.classify.constantize
    end

    # The singular name for the resource class based on the controller
    # @return [String]
    def resource_name
      @resource_name ||= controller_name.singularize
    end

    # Only allow a trusted parameter "white list" through.
    # If a single resource is loaded for #create or #update,
    # then the controller for the resource must implement
    # the method "#{resource_name}_params" to limit permitted
    # parameters for the individual model.
    def resource_params
      @resource_params ||= send("#{resource_name}_params")
    end
  end
end