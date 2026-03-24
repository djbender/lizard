import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="api-key-toggle"
// Toggles between truncated and full API key display.
export default class extends Controller {
  static targets = ["truncated", "full"]

  toggle() {
    this.truncatedTarget.hidden = !this.truncatedTarget.hidden
    this.fullTarget.hidden = !this.fullTarget.hidden
  }
}
