class ProductsController < ApplicationController
  before_filter :find_product, only: [:show, :update]
  def index
    def index
      # TODO: Icky
      @colors = Color.all.sort_by{ |n| n.name }
      @top_level_cats = Category.top_level.sort_by{ |n| n.name }
      @products = Product.all
      render layout: 'product'
    end

    def show
      @user = User.find(params[:id])
    end
  private
    def find_product
      @products = Product.find(params[:id])
    end
  end
end
