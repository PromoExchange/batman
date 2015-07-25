class Spree::Api::LogosController < Spree::Api::BaseController
  before_action :fetch_logo, except: [:index, :create]

  def index
    @logos = Spree::Logo.all
    render 'spree/api/logos/index'
  end

  def show
    @logo = Spree::Logo.find(params[:id])
    render 'spree/api/logos/show'
  end

  def create
    if @logo.present?
      render nothing: true, status: :conflict
    else
      @logo = Spree::Logo.new
      save_logo
    end
  end

  def update
    save_logo
  end

  def destroy
    @logo.destroy
    render nothing: true, status: :ok
  end

  private

  def save_logo
    json = JSON.parse(request.body.read)
    @logo.assign_attributes(
      user_id: json['user_id']
    )
    @logo.save

    @logo.attachment << json['filename']

    @logo.assign_attributes(@json)
    render 'spree/api/logos/show'
  rescue
    render nothing: true, status: :bad_request
  end

  def fetch_logo
    @logo = Spree::Logo.find(params[:id])
  end

  def logo_params
    params.require(:logo).permit(
      :user_id,
      :attachment
    )
  end
end
