class TrailsController < ApplicationController
  def index
    trails = Rails.cache.fetch("all_trails", expires_in: 1.hour) do
      Trail.all.to_json(except: [ :created_at, :updated_at ])
    end
    render json: trails
  end

  def proxy_mapbox
    cached_response = Rails.cache.fetch(params[:url], expires_in: 30.minutes) do
      Net::HTTP.get(URI.parse(params[:url]))
    end
    render json: cached_response
  end
end
