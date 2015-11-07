class Spree::ProductRequestsController < Spree::StoreController
  def create
    @product_request = Spree::ProductRequest.new(product_request_params)

    if @product_request.save
      Resque.enqueue(
        IdeationRequest,
        request_id: @product_request.id
      )
      flash[:notice] = "Your PromoExchange swag pro will have product ideas for you soon!"
      render :js => "window.location = '/dashboards'"
    else
      render nothing: true, status: :unprocessable_entity, json: @product_request.errors.full_messages
    end
  end

  private

  def product_request_params
    params.require(:product_request).permit(:buyer_id, :title, :request, :budget, :quantity, request_type:[])
  end
end
