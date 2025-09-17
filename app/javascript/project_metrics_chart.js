// Project Metrics Chart
// Handles fetching and displaying project metrics using Chart.js

export function initializeProjectChart(metricsUrl) {
  fetch(metricsUrl)
    .then(response => response.json())
    .then(data => {
      const ctx = document.getElementById('metricsChart').getContext('2d');
      new Chart(ctx, {
        type: 'line',
        data: data,
        options: {
          responsive: true,
          interaction: {
            mode: 'index',
            intersect: false,
          },
          scales: {
            x: {
              title: {
                display: true,
                text: 'Date'
              }
            },
            y: {
              type: 'linear',
              display: true,
              position: 'left',
              min: 0,
              max: 100,
              title: {
                display: true,
                text: 'Coverage %'
              }
            },
            y1: {
              type: 'linear',
              display: true,
              position: 'right',
              title: {
                display: true,
                text: 'Spec Count'
              },
              grid: {
                drawOnChartArea: false,
              },
            },
            y2: {
              type: 'linear',
              display: true,
              position: 'right',
              title: {
                display: true,
                text: 'Runtime (seconds)'
              },
              grid: {
                drawOnChartArea: false,
              },
            }
          }
        }
      });
    })
    .catch(error => {
      console.error('Error loading project metrics:', error);
    });
}