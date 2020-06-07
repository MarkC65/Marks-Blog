class ArticlesController < ApplicationController

  def show
    @article = Article.find(params[:id])
  end
  
  def index
    @articles = Article.all
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(params_require)
    #@article.user = current_user
    if @article.save
      flash[:top] = "Article created successfully."
      redirect_to article_path(@article)
    else
      render 'new'
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(params_require)
      flash[:top] = "Article updated successfully."
      redirect_to article_path(@article)
    else
      render 'edit'
    end
  end
  
  private

  def params_require
    params.require(:article).permit(:title, :description)
  end

end 