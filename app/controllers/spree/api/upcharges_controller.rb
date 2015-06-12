class Spree::Api::UpchargesController < Spree::Api::BaseController
  before_action :fetch_upcharge, except: [:index, :create]

  def index
    if params[:product_id].present?
      @upcharges = Spree::Upcharge.where(product_id: params[:product_id])
      render 'spree/api/upcharges/index'
    else
      render nothing: true, status: :bad_request
    end
  end

  def show
    render 'spree/api/upcharges/show'
  end

  def create
    if Spree::Upcharge.exists?(id: params[:id])
      render nothing: true, status: :conflict
    else
      @upcharge = Spree::Upcharge.new
      save_upcharge
    end
  end

  def update
    save_upcharge
  end

  def destroy
    @upcharge.destroy
    render nothing: true, status: :ok
  end

  private

  def upcharge_params
    params.require(:upcharge).permit(:product_id,
      :name,
      :value)
  end

  def fetch_upcharge
    @upcharge = Spree::Upcharge.find(params[:id])
  end

  def save_upcharge
    @json = JSON.parse(request.body.read)
    @upcharge.assign_attributes(@json)
    if @upcharge.save
      render 'spree/api/upcharges/show'
    else
      render nothing: true, status: :bad_request
    end
  end
end
