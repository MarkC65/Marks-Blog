require 'test_helper'

class CreateCategoriesTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create(username: "admin", email: "admin@example.com", display_name: "Administrtion", password: "password", admin: true)
  end

  test "get new category form and create category" do
    sign_in_as(@user, "password")
    # http get the category/new form
    get new_category_path
    # display form
    assert_template 'categories/new'
    # ensure submit to category/create
    assert_difference 'Category.count', 1 do
      post categories_path, params: { "category"=>{"name"=>"Sports"} }
      assert :success
      follow_redirect!
    end
    # confirm the new category is showing in the category/index body
    assert_match "Sports", response.body
  end

  test "invalid category submission results in failure" do
    sign_in_as(@user, "password")
    get new_category_path
    # display form
    assert_template 'categories/new'
    # ensure submit to category/create
    assert_no_difference 'Category.count' do
      post categories_path, params: { "category"=>{"name"=>"N"} }
    end
    assert_template 'categories/new'
    assert_select 'h4.alert-heading'
    assert_select 'div.alert'
  end
end
