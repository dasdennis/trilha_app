class Trail < ApplicationRecord
  acts_as_geocodable

  def reverse_geocode
    centroid = path.point_on_surface
    result = Geocoder.search([ centroid.y, centroid.x ]).first
    update(location: result.address) if result
  end
end
