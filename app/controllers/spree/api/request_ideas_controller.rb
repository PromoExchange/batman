class Spree::Api::RequestIdeasController < Spree::Api::BaseController
  before_action :fetch_request_idea, except: [:index, :create]

  def index
    params[:product_request_id] = {} if params[:product_request_id].blank?
    params[:state] = 'open' if params[:state].blank?

    states = params[:state].split(',')

    @request_ideas = Spree::RequestIdea.search(
      product_request_id_eq: params[:product_request_id],
      state_in: states
    ).result(distinct: true)
    render 'spree/api/request_ideas/index'
  end

  def destroy
    @request_idea.delete!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  def sample_request
    @request_idea.request_sample!
    render nothing: true, status: :ok
  rescue
    render nothing: true, status: :internal_server_error
  end

  private

  def fetch_request_idea
    @request_idea = Spree::RequestIdea.find(params[:id])
    redirect_to '/dashboards' unless current_spree_user.product_requests.include?(@request_idea.product_request)
  end
end
