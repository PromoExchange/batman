class Spree::ProductRequestsController < Spree::StoreController
  def create
    @product_request = Spree::ProductRequest.new(product_request_params)
    if @product_request.save
      Resque.enqueue(
        IdeationRequest,
        request_id: @product_request.id
      )
      redirect_to '/dashboards', flash: { notice: 'Your PromoExchange swag pro will have product ideas for you soon!' }
    else
      redirect_to :back, flash: { error: @product_request.errors.full_messages.first }
    end
  end

  private

  def product_request_params
    params.require(:product_request).permit(:buyer_id, :title, :request)
  end
end
