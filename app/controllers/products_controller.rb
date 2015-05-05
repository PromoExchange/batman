class ProductsController < ApplicationController
  before_filter :find_product, only: [:show, :update]
  def index
    def index
      @top_level_cats = Category.top_level.sort_by{ |n| n.name }
      @products = Product.all
      render layout: 'product'
    end

    def show
      @user = User.find(params[:id])
    end
  end
end
