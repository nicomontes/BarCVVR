require 'test_helper'

class BeerflowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @beerflow = beerflows(:one)
  end

  test "should get index" do
    get beerflows_url
    assert_response :success
  end

  test "should get new" do
    get new_beerflow_url
    assert_response :success
  end

  test "should create beerflow" do
    assert_difference('Beerflow.count') do
      post beerflows_url, params: { beerflow: { drink_id: @beerflow.drink_id, quantity: @beerflow.quantity } }
    end

    assert_redirected_to beerflow_url(Beerflow.last)
  end

  test "should show beerflow" do
    get beerflow_url(@beerflow)
    assert_response :success
  end

  test "should get edit" do
    get edit_beerflow_url(@beerflow)
    assert_response :success
  end

  test "should update beerflow" do
    patch beerflow_url(@beerflow), params: { beerflow: { drink_id: @beerflow.drink_id, quantity: @beerflow.quantity } }
    assert_redirected_to beerflow_url(@beerflow)
  end

  test "should destroy beerflow" do
    assert_difference('Beerflow.count', -1) do
      delete beerflow_url(@beerflow)
    end

    assert_redirected_to beerflows_url
  end
end
