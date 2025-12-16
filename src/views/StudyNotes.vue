<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-cyan-50">
    <!-- Navbar -->
    <nav class="bg-white shadow-xl border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center space-x-6">
            <router-link to="/dashboard" class="text-2xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
              Ed-Eureka
            </router-link>
            <button
              @click="$router.push(`/subject/${subjectId}`)"
              class="text-gray-600 hover:text-purple-600 transition font-medium"
            >
              ← Back to Subject
            </button>
          </div>
          
          <div class="flex items-center space-x-4">
            <span class="text-gray-700 font-medium">{{ userDisplayName }}</span>
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center text-white font-semibold shadow-md">
              {{ userInitials }}
            </div>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>

      <div v-else>
        <div class="mb-8">
          <h1 class="text-4xl font-bold mb-2 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Study Notes - {{ subject?.name }}
          </h1>
          <p class="text-gray-600">Review questions you got wrong and learn from your mistakes</p>
        </div>

        <!-- Statistics Cards -->
        <div class="grid md:grid-cols-4 gap-4 mb-8">
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-red-500">
            <div class="text-2xl font-bold text-red-600">{{ mistakeStats.totalMistakes }}</div>
            <div class="text-sm text-gray-600 mt-1">Total Mistakes</div>
          </div>
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-orange-500">
            <div class="text-2xl font-bold text-orange-600">{{ mistakeStats.uniqueQuestions }}</div>
            <div class="text-sm text-gray-600 mt-1">Unique Questions</div>
          </div>
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-blue-500">
            <div class="text-2xl font-bold text-blue-600">{{ mistakeStats.mistakeRate }}%</div>
            <div class="text-sm text-gray-600 mt-1">Mistake Rate</div>
          </div>
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-500">
            <div class="text-2xl font-bold text-green-600">{{ mistakeStats.improvementRate }}%</div>
            <div class="text-sm text-gray-600 mt-1">Improvement</div>
          </div>
        </div>

        <!-- Filter Options -->
        <div class="bg-white rounded-xl shadow-lg p-4 mb-6 flex flex-wrap items-center gap-4">
          <div class="flex items-center space-x-2">
            <label class="text-sm font-medium text-gray-700">Filter by:</label>
            <select
              v-model="filterBy"
              @change="loadMistakes"
              class="px-3 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
            >
              <option value="all">All Mistakes</option>
              <option value="recent">Recent (Last 7 days)</option>
              <option value="frequent">Most Frequent</option>
            </select>
          </div>
          <div class="flex items-center space-x-2">
            <label class="text-sm font-medium text-gray-700">Sort by:</label>
            <select
              v-model="sortBy"
              @change="loadMistakes"
              class="px-3 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
            >
              <option value="recent">Most Recent</option>
              <option value="frequent">Most Frequent</option>
              <option value="difficulty">Difficulty</option>
            </select>
          </div>
        </div>

        <!-- Mistakes List -->
        <div v-if="mistakes.length === 0" class="bg-white rounded-xl shadow-lg p-12 text-center">
          <div class="text-6xl mb-4">🎉</div>
          <h3 class="text-2xl font-semibold text-gray-800 mb-2">No Mistakes Yet!</h3>
          <p class="text-gray-600 mb-4">Great job! You haven't made any mistakes in this subject yet.</p>
          <p class="text-sm text-gray-500">Start practicing quizzes to track your mistakes and improve.</p>
        </div>

        <div v-else class="space-y-2">
          <div
            v-for="(mistake, index) in mistakes"
            :key="mistake.question_id"
            class="bg-white rounded-lg shadow-sm p-4 border-l-4 border-red-400 hover:shadow-md transition"
          >
            <div class="flex items-start space-x-3">
              <div class="flex-shrink-0 mt-1">
                <div class="w-6 h-6 rounded-full bg-red-100 flex items-center justify-center">
                  <span class="text-xs font-bold text-red-600">{{ index + 1 }}</span>
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center space-x-2 mb-1">
                  <span class="text-xs text-gray-500 font-medium">{{ mistake.difficulty_level || 'medium' }}</span>
                  <span v-if="mistake.timesWrong > 1" class="text-xs text-orange-600 font-medium">
                    (×{{ mistake.timesWrong }})
                  </span>
                </div>
                <div class="text-sm text-gray-700 mb-2">
                  <span class="font-medium text-gray-800">Q:</span> {{ mistake.question_text }}
                </div>
                <div class="space-y-1 text-xs">
                  <div class="flex items-start space-x-2">
                    <span class="text-red-600 font-medium flex-shrink-0">❌</span>
                    <span class="text-gray-600">
                      <span class="font-medium">Wrong:</span> {{ mistake.wrongAnswer }}. {{ getOptionText(mistake, mistake.wrongAnswer) }}
                    </span>
                  </div>
                  <div class="flex items-start space-x-2">
                    <span class="text-green-600 font-medium flex-shrink-0">✅</span>
                    <span class="text-gray-600">
                      <span class="font-medium">Correct:</span> {{ mistake.correct_answer }}. {{ getOptionText(mistake, mistake.correct_answer) }}
                    </span>
                  </div>
                  <div v-if="mistake.explanation" class="flex items-start space-x-2 pt-1">
                    <span class="text-blue-600 font-medium flex-shrink-0">💡</span>
                    <span class="text-gray-700">{{ mistake.explanation }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Analytics Section -->
        <div class="mt-8 bg-white rounded-xl shadow-lg p-6">
          <h2 class="text-2xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Mistake Analytics
          </h2>
          <div class="grid md:grid-cols-2 gap-6">
            <div>
              <h3 class="font-semibold mb-3 text-gray-800">Mistakes Over Time</h3>
              <div v-if="mistakeTimeline.length === 0" class="text-gray-500 text-sm">
                No data available yet
              </div>
              <div v-else class="space-y-2">
                <div
                  v-for="item in mistakeTimeline"
                  :key="item.date"
                  class="flex items-center justify-between"
                >
                  <span class="text-sm text-gray-600">{{ item.date }}</span>
                  <div class="flex-1 mx-4 bg-gray-200 rounded-full h-4">
                    <div
                      class="bg-red-500 h-4 rounded-full"
                      :style="{ width: `${(item.count / maxMistakes) * 100}%` }"
                    ></div>
                  </div>
                  <span class="text-sm font-semibold text-gray-800">{{ item.count }}</span>
                </div>
              </div>
            </div>
            <div>
              <h3 class="font-semibold mb-3 text-gray-800">Most Common Mistakes</h3>
              <div v-if="commonMistakes.length === 0" class="text-gray-500 text-sm">
                No data available yet
              </div>
              <div v-else class="space-y-2">
                <div
                  v-for="(mistake, index) in commonMistakes.slice(0, 5)"
                  :key="mistake.question_id"
                  class="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg"
                >
                  <span class="w-8 h-8 bg-red-500 text-white rounded-full flex items-center justify-center font-bold text-sm">
                    {{ index + 1 }}
                  </span>
                  <div class="flex-1">
                    <p class="text-sm font-medium text-gray-800 line-clamp-2">{{ mistake.question_text }}</p>
                    <p class="text-xs text-gray-500">Made {{ mistake.timesWrong }} time{{ mistake.timesWrong > 1 ? 's' : '' }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useQuizStore } from '../stores/quiz'
import { analyticsService } from '../services/analyticsService'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const quizStore = useQuizStore()

const subjectId = route.params.subjectId
const subject = ref(null)
const loading = ref(true)
const mistakes = ref([])
const filterBy = ref('all')
const sortBy = ref('recent')

const userDisplayName = computed(() => {
  if (!authStore.user) return ''
  return authStore.user.user_metadata?.name || authStore.user.email?.split('@')[0] || 'User'
})

const userInitials = computed(() => {
  const name = userDisplayName.value
  if (!name) return 'U'
  const parts = name.split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase()
  }
  return name[0].toUpperCase()
})

const mistakeStats = computed(() => {
  const totalMistakes = mistakes.value.reduce((sum, m) => sum + m.timesWrong, 0)
  const uniqueQuestions = mistakes.value.length
  const totalAttempts = mistakes.value.reduce((sum, m) => sum + (m.totalAttempts || 0), 0)
  const mistakeRate = totalAttempts > 0 ? Math.round((totalMistakes / totalAttempts) * 100) : 0
  
  // Calculate improvement rate (compare recent vs older mistakes)
  const recentMistakes = mistakes.value.filter(m => {
    if (!m.lastAttempted) return false
    const daysAgo = (new Date() - new Date(m.lastAttempted)) / (1000 * 60 * 60 * 24)
    return daysAgo <= 7
  }).reduce((sum, m) => sum + m.timesWrong, 0)
  
  const olderMistakes = mistakes.value.filter(m => {
    if (!m.lastAttempted) return true
    const daysAgo = (new Date() - new Date(m.lastAttempted)) / (1000 * 60 * 60 * 24)
    return daysAgo > 7
  }).reduce((sum, m) => sum + m.timesWrong, 0)
  
  const improvementRate = olderMistakes > 0 
    ? Math.max(0, Math.round(((olderMistakes - recentMistakes) / olderMistakes) * 100))
    : 0

  return {
    totalMistakes,
    uniqueQuestions,
    mistakeRate,
    improvementRate
  }
})

const mistakeTimeline = computed(() => {
  const timeline = {}
  mistakes.value.forEach(mistake => {
    if (mistake.attemptDates && mistake.attemptDates.length > 0) {
      mistake.attemptDates.forEach(date => {
        const dateStr = new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
        timeline[dateStr] = (timeline[dateStr] || 0) + 1
      })
    }
  })
  
  return Object.entries(timeline)
    .map(([date, count]) => ({ date, count }))
    .sort((a, b) => new Date(a.date) - new Date(b.date))
    .slice(-7) // Last 7 days
})

const maxMistakes = computed(() => {
  return Math.max(...mistakeTimeline.value.map(m => m.count), 1)
})

const commonMistakes = computed(() => {
  return [...mistakes.value].sort((a, b) => b.timesWrong - a.timesWrong)
})

const getOptionText = (mistake, option) => {
  switch (option) {
    case 'A': return mistake.option_a
    case 'B': return mistake.option_b
    case 'C': return mistake.option_c
    case 'D': return mistake.option_d
    default: return ''
  }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
}

const loadMistakes = async () => {
  if (!authStore.user || !subjectId) return
  
  loading.value = true
  try {
    const result = await analyticsService.getMistakes(authStore.user.id, subjectId, filterBy.value, sortBy.value)
    if (result.success) {
      mistakes.value = result.data || []
    } else {
      console.error('Error loading mistakes:', result.error)
      mistakes.value = []
    }
  } catch (error) {
    console.error('Error loading mistakes:', error)
    mistakes.value = []
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await authStore.initialize()
  await quizStore.loadSubjects()
  
  subject.value = quizStore.subjects.find(s => s.id === subjectId)
  await loadMistakes()
})
</script>

