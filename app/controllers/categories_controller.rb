class CategoriesController < ApplicationController
  before_action :require_admin, except: [:index, :show]

  def index
    #Client.order(orders_count: :asc,
    @categories = Category.order(name: :asc).paginate(page: params[:page], per_page: 10)
    #@categories = Category.paginate(page: params[:page], per_page: 10)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(params_require)
    if @category.save
      flash[:top] = "Category created successfully."
      redirect_to categories_path
    else
      render 'new'
    end
  end
  
  def show
    @category = Category.find(params[:id])
    @articles = @category.articles.paginate(page: params[:page], per_page: 10)
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
    if @category.update(params_require)
      flash[:top] = "Category name updated successfully."
      redirect_to categories_path
    else
      render 'edit'
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to categories_path
  end

  private
  
  def params_require
    params.require(:category).permit(:name)
  end

  def require_admin
    if !logged_in? || !current_user.admin?
      flash[:top] = "You are not permitted to perform that action!"
      redirect_to categories_path
    end
  end

end