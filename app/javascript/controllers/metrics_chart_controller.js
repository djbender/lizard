import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="metrics-chart"
// Fetches project metrics JSON and renders a Chart.js line chart.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.#loadChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  // Private method (ES2022 private class field syntax — not accessible outside the class)
  #loadChart() {
    fetch(this.urlValue)
      .then(response => response.json())
      .then(data => {
        if (!this.element.isConnected) return

        this.chart = new Chart(this.element, {
          type: "line",
          data: data,
          options: {
            responsive: true,
            interaction: { mode: "index", intersect: false },
            scales: {
              x: {
                title: { display: true, text: "Date" }
              },
              y: {
                type: "linear",
                display: true,
                position: "left",
                min: 0,
                max: 100,
                title: { display: true, text: "Coverage %" }
              },
              y1: {
                type: "linear",
                display: true,
                position: "right",
                title: { display: true, text: "Spec Count" },
                grid: { drawOnChartArea: false }
              },
              y2: {
                type: "linear",
                display: true,
                position: "right",
                title: { display: true, text: "Runtime (seconds)" },
                grid: { drawOnChartArea: false }
              }
            }
          }
        })
      })
      .catch(error => {
        console.error("Error loading project metrics:", error)
      })
  }
}
