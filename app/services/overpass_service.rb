class OverpassService
  def self.fetch_trails(bbox)
    Rails.cache.fetch("trails#{bbox}", expires_in: 12.hours) do
      overpass = OverpassAPI.new(timeout = 30)
      query = <<~QUERY
        [out:json][timeout:30];
        way[highway=path][foot=designated](#{bbox});
        out body geom;
      QUERY

      process_response(overpass.query(query))
    end
  rescure => e
    Rails.logger.error "Overpass error: #{e.message}"
  end

  private

  # Processes the Overpass API response to extract trail data
  # and create Trail records.
  # Continue from here
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
