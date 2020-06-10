require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  def setup
    @category = Category.new(name: "sports")
  end

  test "category must be valid" do
    assert @category.valid?
  end
    
  test "name must be present" do
    @category.name = " "
    assert_not @category.valid?
  end
    
  test "name must be unique" do
    @category.save
    category2 = Category.new(name: "sports")
    assert_not category2.valid?
  end
    
  test "name must not be too long" do
    @category.name = "a" * 36
    assert_not @category.valid?
  end
    
  test "max name length must be 25" do
    @category.name = "a" * 35
    assert @category.valid?
  end

  test "name must not be too short" do
    @category.name = "aa"
    assert_not @category.valid?
  end

  test "min name length must be 3" do
    @category.name = "a" * 3
    assert @category.valid?
  end
  
end