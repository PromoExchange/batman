class Spree::Api::RequestIdeasController < Spree::Api::BaseController
  before_action :fetch_request_idea, except: [:index, :create]

  def index
    params[:buyer_id] = {} if params[:buyer_id].blank?
    params[:state] = 'open' if params[:state].blank?

    states = params[:state].split(',')

    @request_ideas = Spree::RequestIdea.search(
      product_request_buyer_id_eq: params[:buyer_id],
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
    redirect_to '/dashboards' unless current_spree_user.product_request == @request_idea.product_request
  end
end
