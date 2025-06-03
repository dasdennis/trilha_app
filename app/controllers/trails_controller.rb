class TrailsController < ApplicationController
  before_action :validate_mapbox_url, only: :proxy_mapbox

  def index
    render json: Trail.all.map(&:as_geojson)
  end

  def proxy_mapbox
    if rate_limited?
      return head :too_many_requests
    end

    url = safe_mapbox_url
    cache_key = "mapbox_proxy: #{Digest::SHA256.hexdigest(url)}"

    data = Rails.cache.fetch(cache_key, expire_in: 30.minutes) do
      Net::HTTP.get(URI.parse(url))
    end

    render json: data
  end

  private

  # Checks if the request exceeds the rate limit
  def rate_limited?
    key = "#{request.remote_ip}_mapbox"
    Rack::Attack.cache.store.increment(key, 1, expires_in: 1.minute) > 50
  end

  # Validates the Mapbox URL and raises if invalid
  def validate_mapbox_url
    safe_mapbox_url
  rescue URI::InvalidURIError
    head :bad_request
  end

  # Returns the validated Mapbox URL or raises
  def safe_mapbox_url
    url = params.require(:url)
    uri = URI.parse(url)
    allowed_hosts = %w[api.mapbox.com tiles.mapbox.com]
    allowed_paths = %w[/v4/mapbox.mapbox-streets-v8 /geocoding/v5/mapbox.places]

    unless allowed_hosts.include?(uri.host) && allowed_paths.any? { |p| uri.path.start_with?(p) }
      raise ActionController::RoutingError, "Not Found"
    end

    url
  end

  def import
    # unless current_user&.admin?
    #   return head :forbidden
    # end

    bbox = params[:bbox].to_s
    # Simple bbox validation: four comma-separated floats
    unless bbox.match?(/\A-?\d+(\.\d+)?,-?\d+(\.\d+)?,-?\d+(\.\d+)?,-?\d+(\.\d+)?\z/)
      return render json: { error: "Invalid bbox format" }, status: :bad_request
    end

    OverpassService.fetch_trails(bbox)
    render json: { status: "Import started" }, status: :accepted
  rescue => e
    Rails.logger.error("Import failed: #{e.class} - #{e.message}")
    render json: { error: "Import failed" }, status: :internal_server_error
  end
end

# To Do:
# Replace current_user&.admin? when add authentication and authorization for import and proxy actions.
