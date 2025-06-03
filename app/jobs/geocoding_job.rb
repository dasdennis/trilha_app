class GeocodingJob < ApplicationJob
  queue_as :low_priority

  def perform(trail_id)
    trail = Trail.find(trail_id)
    if trail.reverse_geocode
      trail.save
    else
      log_geocode_failure(trail)
    end

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Geocoding failed: Trail not found (id=#{trail_id})")
  rescue StandardError => e
    Rails.logger.error("Geocoding failed for Trail id=#{trail_id}: #{e.class} - #{e.message}")
  end

  private

  def log_geocode_failure(trail)
    if trail.latitude && trail.longitude
      Rails.logger.warn("No geocoding results for Trail id=#{trail.id} at [#{trail.latitude},#{trail.longitude}]")
    else
      Rails.logger.warn("No geocoding results: Trail id=#{trail.id} missing coordinates")
    end
  end
end
