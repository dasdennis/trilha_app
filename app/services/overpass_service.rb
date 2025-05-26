class OverpassService
  def self.fetch_trails(bbox)
    Rails.cache.fetch("trails#{bbox}", expires_in: 12.hours) do
      overpass = OverpassAPI.new
      query = "[out:json];way[highway=path][foot=designated](#{bbox});out geom;"
      response = overpass.query(query)
      process_response(response)
    end
  end

  private

  def self.process_response(response)
    response[:elements].filter_map do |element|
      next unless element[:geometry]

      coordinates = element[:geometry].map { |pt| "#{pt[:lon]} #{pt[:lat]}" }
      Trail.create!(
        name: element.dig(:tags, :name) || "Unnamed Trail",
        difficulty: element.dig(:tags, :sac_scale) || "Unknown",
        path: "LINESTRING(#{coordinates.join(',')})"
      )
    end
  end
end
