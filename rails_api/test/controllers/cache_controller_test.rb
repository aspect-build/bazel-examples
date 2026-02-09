# frozen_string_literal: true

require_relative "../test_helper"

class CacheControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def setup
    @container = Testcontainers::DockerContainer.new("memcached:alpine").with_exposed_port(11211)
    @container.start

    # Get the mapped port and configure Rails to use the containerized memcached
    port = @container.mapped_port(11211)
    Rails.application.config.cache_store = :mem_cache_store, "localhost:#{port}", { namespace: "test" }
    Rails.cache = ActiveSupport::Cache.lookup_store(*Rails.application.config.cache_store)

    # Clear any existing test keys
    Rails.cache.delete("test_key")
    Rails.cache.delete("delete_me")
  end

  def teardown
    @container.stop
    @container.delete
  end

  def test_store_and_retrieve_value
    # Store a value
    post "/cache", key: "test_key", value: "test_value", ttl: 60

    assert_equal 201, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "test_key", json["key"]
    assert_equal "test_value", json["value"]
    assert json["stored"]

    # Retrieve it
    get "/cache/test_key"

    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal "test_key", json["key"]
    assert_equal "test_value", json["value"]
    assert json["cached"]
  end

  def test_retrieve_nonexistent_key_returns_404
    get "/cache/nonexistent_key_12345"

    assert_equal 404, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "Key not found", json["error"]
  end

  def test_store_requires_key_and_value
    post "/cache", key: "only_key"

    assert_equal 400, last_response.status
    json = JSON.parse(last_response.body)
    assert_equal "key and value are required", json["error"]
  end

  def test_delete_cached_value
    # First store a value
    Rails.cache.write("delete_me", "goodbye")

    # Delete it
    delete "/cache/delete_me"

    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert_equal "delete_me", json["key"]
    assert json["deleted"]

    # Verify it's gone
    get "/cache/delete_me"
    assert_equal 404, last_response.status
  end

  def test_cache_stats
    get "/cache/stats"

    # Stats endpoint should return 200 if memcached is running
    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert json.key?("stats") || json.key?("message")
  end
end
