// API Key Toggle Utility
// Toggles between showing truncated and full API key display

export function toggleApiKey() {
  const truncatedElement = document.getElementById('api-key-display');
  const fullElement = document.getElementById('api-key-full');

  if (truncatedElement.style.display === 'none') {
    truncatedElement.style.display = 'inline';
    fullElement.style.display = 'none';
  } else {
    truncatedElement.style.display = 'none';
    fullElement.style.display = 'inline';
  }
}

// Make function globally available for onclick handlers
window.toggleApiKey = toggleApiKey;