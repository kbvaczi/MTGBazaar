require 'test_helper'

class AccountDepositsControllerTest < ActionController::TestCase
  setup do
    @users_deposit = users_deposits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:account_deposits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create users_deposit" do
    assert_difference('AccountDeposit.count') do
      post :create, users_deposit: @users_deposit.attributes
    end

    assert_redirected_to users_deposit_path(assigns(:account_deposit))
  end

  test "should show users_deposit" do
    get :show, id: @users_deposit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @users_deposit
    assert_response :success
  end

  test "should update users_deposit" do
    put :update, id: @users_deposit, users_deposit: @users_deposit.attributes
    assert_redirected_to users_deposit_path(assigns(:account_deposit))
  end

  test "should destroy users_deposit" do
    assert_difference('AccountDeposit.count', -1) do
      delete :destroy, id: @users_deposit
    end

    assert_redirected_to users_deposits_path
  end
end
