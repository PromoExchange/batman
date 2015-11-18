class Spree::Admin::ProductRequestsController < Spree::Admin::BaseController
  def index
    @product_requests = Spree::ProductRequest.order('id asc')
  end

  def create
    @product_request = Spree::ProductRequest.find(params[:id])

    params[:cost] = 0 if params[:cost].blank?

    @request_idea = @product_request.request_ideas.new(
      sku: params[:sku],
      cost: params[:cost]
    )

    if @request_idea.save
      @product_request.pending_notification if @product_request.complete?
      render json: { nothing: true, status: :ok, error_msg: '' }
    else
      render json: { nothing: true, status: :bad_request, error_msg: @request_idea.errors.full_messages }
    end
  rescue
    render json: { nothing: true, status: :internal_server_error }
  end

  def destroy_idea
    @request_idea = Spree::RequestIdea.find(params[:request_idea_id])
    @request_idea.destroy
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def update_idea
    @request_idea = Spree::RequestIdea.find(params[:request_idea_id])
    @request_idea.update_attributes(
      cost: params[:cost]
    )
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def generate_notification
    @product_request = Spree::ProductRequest.find(params[:id])
    @product_request.generate_notification!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end
end
