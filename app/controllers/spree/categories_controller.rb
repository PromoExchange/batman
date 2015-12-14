class Spree::CategoriesController < Spree::StoreController
  def index
    @taxon = Spree::Taxon.where(name: 'Categories').take
    @categories = @taxon.children
  end

  private

  def require_login
    redirect_to login_url unless current_spree_user
  end
end