class Trail < ApplicationRecord
  # Reverse geocoding after creation using centroid coordinates
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if (geo = results.first)
      obj.location = "#{geo.city}, #{geo.country}"
    end
  end

  after_commit :queue_reverse_geocode, on: :create

  validates :name, :difficulty, :path, :osm_id, presence: true

  def latitude
    path&.point_on_surface&.y
  end

  def longitude
    path&.point_on_surface&.x
  end

  def as_geojson
    return nil unless path
    RGeo::GeoJSON.encode(
      RGeo::GeoJSON::Feature.new(
        path,
        id,
        name: name,
        difficulty: difficulty
      )
    )
  end

  private

  def queue_reverse_geocode
    GeocodingJob.perform_later(id)
  end
end
