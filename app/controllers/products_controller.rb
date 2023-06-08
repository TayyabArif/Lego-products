class ProductsController < ApplicationController
  def index
    @check = true
    @q = Product.ransack(params[:q])
    @products = []
    if params[:q]
    @products = params[:q][:name_cont].blank? ? [] : @q.result.paginate(page: params[:page])
    end
    @check = params[:q] && params[:q][:name_cont].blank?
  end

  def price_condition
    @product = Product.find(params[:id])
  end
end
