class Spree::Api::PrebidsController < Spree::Api::BaseController
  before_action :fetch_prebid, except: [:index, :create]

  def index
    if params[:seller_id].present?
      @prebids = Spree::Prebid.where(seller_id: params[:seller_id])
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    else
      @prebids = Spree::Prebid.all
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    end

    render 'spree/api/prebids/index'
  end

  def show
    render 'spree/api/prebids/show'
  end

  def create
    if Spree::Prebid.exists?(id: params[:id])
      render nothing: true, status: :conflict
    else
      @prebid = Spree::Prebid.new
      save_prebid
    end
  end

  def update
    save_prebid
  end

  def destroy
    @prebid.destroy
    render nothing: true, status: :ok
  end

  private

  def fetch_prebid
    @prebid = Spree::Prebid.find(params[:id])
  end

  def save_prebid
    @json = JSON.parse(request.body.read)
    @prebid.assign_attributes(@json)
    if @prebid.save!
      render 'spree/api/prebids/show'
    else
      render nothing: true, status: :bad_request
    end
  end

  def prebid_params
    params.require(:prebid).permit(
      :seller_id,
      :supplier_id,
      :eqp,
      :live,
      :eqp_discount
    )
  end
end
