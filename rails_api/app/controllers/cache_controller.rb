# frozen_string_literal: true

class CacheController < ApplicationController
  # GET /cache/:key
  # Retrieve a value from memcached
  def show
    key = params[:key]
    value = Rails.cache.read(key)

    if value
      render json: { key: key, value: value, cached: true }
    else
      render json: { key: key, error: "Key not found" }, status: :not_found
    end
  end

  # POST /cache
  # Store a value in memcached
  # Params: key, value, ttl (optional, in seconds)
  def create
    key = params[:key]
    value = params[:value]
    ttl = params[:ttl]&.to_i || 300 # Default 5 minutes

    if key.blank? || value.blank?
      render json: { error: "key and value are required" }, status: :bad_request
      return
    end

    Rails.cache.write(key, value, expires_in: ttl.seconds)
    render json: { key: key, value: value, ttl: ttl, stored: true }, status: :created
  end

  # DELETE /cache/:key
  # Remove a value from memcached
  def destroy
    key = params[:key]
    deleted = Rails.cache.delete(key)

    render json: { key: key, deleted: deleted }
  end

  # GET /cache/stats
  # Get memcached connection stats
  def stats
    cache = Rails.cache
    if cache.respond_to?(:stats)
      render json: { stats: cache.stats }
    else
      render json: { message: "Stats not available for this cache store" }
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :service_unavailable
  end
end
