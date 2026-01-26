# frozen_string_literal: true

require_relative "../test_helper"

class ItemsControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def test_index_returns_all_items
    get "/items"

    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 3, json["items"].length
  end

  def test_show_returns_single_item
    get "/items/1"

    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal 1, json["id"]
    assert_equal "Widget", json["name"]
  end

  def test_show_returns_not_found_for_invalid_id
    get "/items/999"

    assert_equal 404, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "Item not found", json["error"]
  end

  def test_create_returns_new_item
    post "/items", name: "New Item", price: 39.99

    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "New Item", json["name"]
    assert_equal 39.99, json["price"]
  end
end
