# frozen_string_literal: true

require_relative "../test_helper"

class HealthControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def test_health_check_returns_ok
    get "/health"

    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal "ok", json["status"]
    assert json["timestamp"]
  end
end
