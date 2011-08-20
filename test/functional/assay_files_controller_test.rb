require 'test_helper'

class AssayFilesControllerTest < ActionController::TestCase
  setup do
    @assay_file = assay_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assay_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assay_file" do
    assert_difference('AssayFile.count') do
      post :create, :assay_file => @assay_file.attributes
    end

    assert_redirected_to assay_file_path(assigns(:assay_file))
  end

  test "should show assay_file" do
    get :show, :id => @assay_file.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @assay_file.to_param
    assert_response :success
  end

  test "should update assay_file" do
    put :update, :id => @assay_file.to_param, :assay_file => @assay_file.attributes
    assert_redirected_to assay_file_path(assigns(:assay_file))
  end

  test "should destroy assay_file" do
    assert_difference('AssayFile.count', -1) do
      delete :destroy, :id => @assay_file.to_param
    end

    assert_redirected_to assay_files_path
  end
end
