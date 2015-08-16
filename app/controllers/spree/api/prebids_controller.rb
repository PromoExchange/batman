class Spree::Api::PrebidsController < Spree::Api::BaseController
  before_action :fetch_prebid, except: [:index, :create, :factory_prebid]

  def index
    if params[:buyer_id].present?
      @prebids = Spree::Prebid.where(buyer_id: params[:buyer_id])
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    else
      @prebids = Spree::Prebid.all
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    end

    render 'spree/api/prebids/index'
  end

  def factory_prebid
    # TODO: f it
    # For this seller, every factory (we only have one ATM), every product
    # hack a prebid record
    Spree::Prebid.where(seller_id: params[:seller_id]).destroy_all
    products = Spree::Product.all
    products.each do |p|
      Spree::Prebid.create(
        seller_id: params[:seller_id],
        product_id: p.id,
        eqp: params[:eqp_flag],
        eqp_discount: params[:eqp_discount],
        markup: params[:markup]
      )
    end
    render nothing: true, status: :ok
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
    if @prebid.save
      render 'spree/api/prebids/show'
    else
      render nothing: true, status: :bad_request
    end
  end

  def prebid_params
    params.require(:prebid).permit(
      :taxon_id,
      :seller_id,
      :description,
      :page,
      :per_page
    )
  end
end
