class Rack::Attack
  # Allow all local traffic
  safelist("allow-localhost") do |req|
    "127.0.0.1" == req.ip || "::1" == req.ip
  end

  # Throttle requests to 50 requests per minute per IP for mapbox proxy
  throttle("mapbox/proxy", limit: 50, period: 1.minute) do |req|
    if req.path == "/trails/proxy_mapbox" # Update with the actual Route
      req.ip
    end
  end
end

# For production, consider use Redis for better performance
# Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV["REDIS_URL"])
