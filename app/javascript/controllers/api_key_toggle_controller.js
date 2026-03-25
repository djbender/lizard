import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="api-key-toggle"
// Toggles between truncated and full API key display.
export default class extends Controller {
  static targets = ["truncated", "full"]

  toggle() {
    this.truncatedTarget.hidden = !this.truncatedTarget.hidden
    this.fullTarget.hidden = !this.fullTarget.hidden

    if (!this.fullTarget.hidden) {
      const selection = window.getSelection()
      const range = document.createRange()
      range.selectNodeContents(this.fullTarget)
      selection.removeAllRanges()
      selection.addRange(range)
    }
  }
}
