<template>
  <div class="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
    <h3 class="text-xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">{{ title }}</h3>
    <div v-if="loading" class="flex justify-center items-center h-64">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
    </div>
    <div v-else-if="!chartData || chartData.length === 0" class="text-center text-gray-500 py-12">
      No data available yet. Start practicing to see your progress!
    </div>
    <div v-else ref="chartContainer" class="h-64">
      <canvas ref="chartCanvas"></canvas>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick } from 'vue'
import {
  Chart,
  CategoryScale,
  LinearScale,
  BarElement,
  BarController,
  LineElement,
  LineController,
  PointElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'

Chart.register(
  CategoryScale,
  LinearScale,
  BarElement,
  BarController,
  LineElement,
  LineController,
  PointElement,
  Title,
  Tooltip,
  Legend
)

const props = defineProps({
  title: {
    type: String,
    default: 'Analytics'
  },
  chartData: {
    type: Array,
    default: () => []
  },
  chartType: {
    type: String,
    default: 'bar', // 'bar' or 'line'
    validator: (value) => ['bar', 'line'].includes(value)
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const chartContainer = ref(null)
const chartCanvas = ref(null)
let chartInstance = null

const createChart = async () => {
  await nextTick()
  
  if (!chartCanvas.value || !props.chartData || props.chartData.length === 0) {
    // Destroy chart if no data
    if (chartInstance) {
      chartInstance.destroy()
      chartInstance = null
    }
    return
  }

  // Destroy existing chart before creating new one
  if (chartInstance) {
    try {
      chartInstance.destroy()
    } catch (error) {
      console.warn('Error destroying chart:', error)
    }
    chartInstance = null
  }

  // Wait a bit to ensure canvas is free
  await nextTick()

  const ctx = chartCanvas.value.getContext('2d')
  
  if (!ctx) {
    console.error('Could not get canvas context')
    return
  }

  // Prepare data based on chart type
  const labels = props.chartData.map(item => {
    if (item.practice_date) {
      return new Date(item.practice_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    }
    return item.label || 'Unknown'
  })

  const dataValues = props.chartData.map(item => {
    if (item.average_score !== undefined) {
      return item.average_score
    }
    if (item.questions_attempted !== undefined) {
      return item.questions_attempted
    }
    return item.value || 0
  })

  chartInstance = new Chart(ctx, {
    type: props.chartType,
    data: {
      labels: labels,
      datasets: [
        {
          label: props.chartType === 'bar' ? 'Questions Attempted' : 'Average Score',
          data: dataValues,
          backgroundColor: props.chartType === 'bar' 
            ? 'rgba(147, 51, 234, 0.5)' 
            : 'rgba(59, 130, 246, 0.3)',
          borderColor: props.chartType === 'bar'
            ? 'rgba(147, 51, 234, 1)'
            : 'rgba(59, 130, 246, 1)',
          borderWidth: 2,
          tension: props.chartType === 'line' ? 0.4 : 0
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: true,
          position: 'top'
        },
        tooltip: {
          mode: 'index',
          intersect: false
        }
      },
      scales: {
        y: {
          beginAtZero: true
        }
      }
    }
  })
}

watch(() => props.chartData, () => {
  if (!props.loading) {
    createChart()
  }
}, { deep: true })

watch(() => props.chartType, () => {
  if (!props.loading) {
    createChart()
  }
})

watch(() => props.loading, (newLoading) => {
  if (!newLoading && props.chartData && props.chartData.length > 0) {
    createChart()
  }
})

onMounted(() => {
  if (!props.loading) {
    createChart()
  }
})

// Cleanup on unmount
onUnmounted(() => {
  if (chartInstance) {
    try {
      chartInstance.destroy()
    } catch (error) {
      console.warn('Error destroying chart on unmount:', error)
    }
    chartInstance = null
  }
})
</script>

