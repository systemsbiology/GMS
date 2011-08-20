require 'test_helper'

class SampleAssaysControllerTest < ActionController::TestCase
  setup do
    @sample_assay = sample_assays(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sample_assays)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sample_assay" do
    assert_difference('SampleAssay.count') do
      post :create, :sample_assay => @sample_assay.attributes
    end

    assert_redirected_to sample_assay_path(assigns(:sample_assay))
  end

  test "should show sample_assay" do
    get :show, :id => @sample_assay.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @sample_assay.to_param
    assert_response :success
  end

  test "should update sample_assay" do
    put :update, :id => @sample_assay.to_param, :sample_assay => @sample_assay.attributes
    assert_redirected_to sample_assay_path(assigns(:sample_assay))
  end

  test "should destroy sample_assay" do
    assert_difference('SampleAssay.count', -1) do
      delete :destroy, :id => @sample_assay.to_param
    end

    assert_redirected_to sample_assays_path
  end
end
