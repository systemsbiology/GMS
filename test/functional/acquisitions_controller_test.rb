require 'test_helper'

class AcquisitionsControllerTest < ActionController::TestCase
  setup do
    @acquisition = acquisitions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:acquisitions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create acquisition" do
    assert_difference('Acquisition.count') do
      post :create, :acquisition => @acquisition.attributes
    end

    assert_redirected_to acquisition_path(assigns(:acquisition))
  end

  test "should show acquisition" do
    get :show, :id => @acquisition.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @acquisition.to_param
    assert_response :success
  end

  test "should update acquisition" do
    put :update, :id => @acquisition.to_param, :acquisition => @acquisition.attributes
    assert_redirected_to acquisition_path(assigns(:acquisition))
  end

  test "should destroy acquisition" do
    assert_difference('Acquisition.count', -1) do
      delete :destroy, :id => @acquisition.to_param
    end

    assert_redirected_to acquisitions_path
  end
end
