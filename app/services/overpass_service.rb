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
  rescue => e
    Rails.logger.error "Overpass error: #{e.message}"
    []
  end

  private

  # Processes the Overpass API response to extract trail data and create Trail records.
  def self.process_response(response)
    response[:elements].each_with_object([]) do |element, acc|
      next unless valid_element?(element)

      acc << Trail.create_with(
        name: element.dig(:tags, :name) || "Trail ##{element[:id]}",
        difficulty: sanitize_difficulty(element.dig(:tags, :sac_scale)),
        path: build_linestring(element[:geometry])
      ).find_or_create_by!(osm_id: element[:id])
    end
  end

  # Validates if the element is a way with a geometry of more than one point.
  def self.valid_element?(element)
    element[:type] == "way" && element[:geometry]&.size.to_i > 1
  end

  # Builds a LINESTRING from the geometry points in the Overpass response.
  def self.build_linestring(geometry)
    points = geometry.map { |pt| "POINT(#{pt[:lon]} #{pt[:lat]})" }
    Trail.rgeo_factory_for_column(:path).parse("LINESTRING(#{points.join(', ')})")
  end

  # Sanitizes the difficulty input to ensure it is one of the expected values.
  # If not, it defaults to 'unknown'.
  def self.sanitize_difficulty(input)
    %w[easy moderate difficult unknown].include?(input) ? input : "unknown"
  end
end
