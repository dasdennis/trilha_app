import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  connect() {
    // Securely get Mapbox token
    const tokenMeta = document.head.querySelector('meta[name="mapbox-token"]').content
    fetch('/trails/import', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ bbox: '...' })
    })

    if (!tokenMeta) {
      console.error("Mapbox token meta tag not found.")
      return
    }
    mapboxgl.accessToken = tokenMeta.content

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12"
    })

    this.map.on("load", () => this.loadTrails())
    this.map.on("error", (e) => {
      console.error("Mapbox error:", e && e.error)
    })
  }

  async loadTrails() {
    try {
      const response = await fetch("/trails.json")
      if (!response.ok) throw new Error(`Failed to fetch trails: ${response.status}`)
      const data = await response.json()

      // Prevent duplicate source/layer
      if (this.map.getSource("trails")) {
        this.map.getSource("trails").setData(data)
      } else {
        this.map.addSource("trails", { type: "geojson", data })
        this.map.addLayer({
          id: "trails-line",
          type: "line",
          source: "trails",
          paint: {
            "line-color": "#ff0000",
            "line-width": 3
          }
        })
      }
    } catch (error) {
      console.error("Error loading trails:", error)
    }
  }
}
