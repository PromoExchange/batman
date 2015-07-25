class Spree::Api::FavoritesController < Spree::Api::BaseController
  before_action :fetch_favorite, except: [:index, :create]

  def index
    if params[:buyer_id].present?
      if params[:product_id].present?
        @favorites = Spree::Favorite
          .where(buyer_id: params[:buyer_id])
          .where(product_id: params[:product_id])
      else
        @favorites = Spree::Favorite
          .where(buyer_id: params[:buyer_id])
          .page(params[:page])
          .per(params[:per_page] || Spree::Config[:orders_per_page])
      end
    else
      @favorites = Spree::Favorite.all
        .page(params[:page])
        .per(params[:per_page] || Spree::Config[:orders_per_page])
    end

    render 'spree/api/favorites/index'
  end

  def show
    render 'spree/api/favorites/show'
  end

  def create
    if Spree::Favorite.exists?(id: params[:id])
      render nothing: true, status: :conflict
    else
      @favorite = Spree::Favorite.new
      save_favorite
    end
  end

  def update
    save_favorite
  end

  def destroy
    @favorite.destroy
    render nothing: true, status: :ok
  end

  private

  def fetch_favorite
    @favorite = Spree::Favorite.find(params[:id])
  end

  def save_favorite
    @json = JSON.parse(request.body.read)
    @favorite.assign_attributes(@json)
    if @favorite.save
      render 'spree/api/favorites/show'
    else
      render nothing: true, status: :bad_request
    end
  end

  def favorite_params
    params.require(:favorite).permit(
      :buyer_id,
      :product_id,
      :page,
      :per_page
    )
  end
end
