# frozen_string_literal: true

class ItemsController < ApplicationController
  # In-memory store for demonstration
  ITEMS = [
    { id: 1, name: "Widget", price: 9.99 },
    { id: 2, name: "Gadget", price: 19.99 },
    { id: 3, name: "Gizmo", price: 29.99 }
  ].freeze

  def index
    render json: { items: ITEMS }
  end

  def show
    item = ITEMS.find { |i| i[:id] == params[:id].to_i }
    if item
      render json: item
    else
      render json: { error: "Item not found" }, status: :not_found
    end
  end

  def create
    item = {
      id: ITEMS.length + 1,
      name: params[:name],
      price: params[:price].to_f
    }
    render json: item, status: :created
  end
end
