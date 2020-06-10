class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def show
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
  end

  def update
    if @article.update(params_require)
      flash[:top] = "Article updated successfully."
      redirect_to article_path(@article)
    else
      render 'edit'
    end
  end
  
  def destroy
    @article.destroy
    redirect_to articles_path
  end

  private

  def set_article
    @article = Article.find(params[:id])
    # @article_comment_ct = @article.article_comments.count
    # @article_comments = @article.article_comments.order(updated_at: :DESC).paginate(page: params[:page], per_page: 5)
  end

  def params_require
    params.require(:article).permit(:title, :description)
  end

end 