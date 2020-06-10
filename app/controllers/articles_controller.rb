class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :require_login, except: [:show, :index]
  before_action :require_same_user, except: [:show, :index, :new, :create]

  def show
  end
  
  def index
    # @articles = Article.all
    @articles = Article.paginate(page: params[:page], per_page: 10)
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(params_require)
    @article.user = current_user
    if @article.save
      flash[:top] = "Article created successfully."
      redirect_to article_path(@article)
    else
      render 'new'
    end
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
    @article_comment_ct = @article.article_comments.count
    @article_comments = @article.article_comments.order(updated_at: :DESC).paginate(page: params[:page], per_page: 5)
  end

  def params_require
    params.require(:article).permit(:title, :description, category_ids: [])
  end

  def require_same_user
    if (current_user != @article.user) && (!current_user.admin?)
      flash[:top] = "You are not permitted to perform that action!"
      redirect_to article_path(@article)
    end
  end

end