require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
    @user = users(:one)
  end

  # test "should get index" do
  #   get articles_path
  #   assert_response :success
  # end

  # test "should get new" do
  #   get new_article_path
  #   assert_response :success
  # end

  # test "should create article" do
  #   assert_difference('Article.count') do
  #     post articles_path, params: { article: { description: @article.description, title: @article.title } }
  #   end

  #   assert_redirected_to article_path(Article.last)
  # end

  # test "should show article" do
  #   get article_path(@article)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_article_path(@article)
  #   assert_response :success
  # end

  # test "should update article" do
  #   patch article_path(@article), params: { article: { description: @article.description, title: @article.title } }
  #   assert_redirected_to article_url(@article)
  # end

  # test "should destroy article" do
  #   assert_difference('Article.count', -1) do
  #     delete article_path(@article)
  #   end

  #   assert_redirected_to articles_path
  # end
end
