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
              @click="$router.push('/dashboard')"
              class="text-gray-600 hover:text-purple-600 transition font-medium"
            >
              ← Back to Dashboard
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
      <div class="mb-8">
        <h1 class="text-4xl font-bold mb-2 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
          Progress Reports
        </h1>
        <p class="text-gray-600">View detailed reports of your learning progress</p>
      </div>

      <!-- Report Options -->
      <div class="mb-6 flex flex-wrap items-center gap-4">
        <div>
          <label class="text-sm font-medium text-gray-700 mr-2">Subject:</label>
          <select
            v-model="selectedSubjectId"
            @change="generateReport"
            class="px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 bg-white"
          >
            <option :value="null">All Subjects</option>
            <option
              v-for="subject in quizStore.subjects"
              :key="subject.id"
              :value="subject.id"
            >
              {{ subject.name }}
            </option>
          </select>
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 mr-2">Period:</label>
          <select
            v-model="reportPeriod"
            @change="generateReport"
            class="px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 bg-white"
          >
            <option value="week">Last Week</option>
            <option value="month">Last Month</option>
            <option value="3months">Last 3 Months</option>
            <option value="all">All Time</option>
          </select>
        </div>
        <button
          @click="exportReport"
          class="px-6 py-2 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition shadow-lg font-semibold"
        >
          📄 Export Report
        </button>
      </div>

      <!-- Report Content -->
      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>

      <div v-else class="space-y-6">
        <!-- Summary Cards -->
        <div class="grid md:grid-cols-4 gap-4">
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-blue-500">
            <div class="text-2xl font-bold text-blue-600">{{ reportData.totalQuizzes }}</div>
            <div class="text-sm text-gray-600 mt-1">Total Quizzes</div>
          </div>
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-green-500">
            <div class="text-2xl font-bold text-green-600">{{ reportData.totalQuestions }}</div>
            <div class="text-sm text-gray-600 mt-1">Questions Attempted</div>
          </div>
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
            <div class="text-2xl font-bold text-purple-600">{{ reportData.averageScore.toFixed(1) }}%</div>
            <div class="text-sm text-gray-600 mt-1">Average Score</div>
          </div>
          <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-orange-500">
            <div class="text-2xl font-bold text-orange-600">{{ reportData.studyStreak }}</div>
            <div class="text-sm text-gray-600 mt-1">Day Streak</div>
          </div>
        </div>

        <!-- Subject Breakdown -->
        <div class="bg-white rounded-xl shadow-lg p-6">
          <h3 class="text-xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Subject Breakdown
          </h3>
          <div class="space-y-4">
            <div
              v-for="subject in reportData.subjectBreakdown"
              :key="subject.id"
              class="p-4 bg-gray-50 rounded-lg"
            >
              <div class="flex justify-between items-center mb-2">
                <span class="font-semibold text-gray-800">{{ subject.name }}</span>
                <span class="text-sm font-semibold text-purple-600">{{ subject.averageScore.toFixed(1) }}%</span>
              </div>
              <div class="grid grid-cols-3 gap-4 text-sm text-gray-600">
                <div>Quizzes: <span class="font-medium">{{ subject.quizzes }}</span></div>
                <div>Questions: <span class="font-medium">{{ subject.questions }}</span></div>
                <div>Mistakes: <span class="font-medium text-red-600">{{ subject.mistakes }}</span></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Activity -->
        <div class="bg-white rounded-xl shadow-lg p-6">
          <h3 class="text-xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Recent Activity
          </h3>
          <div class="space-y-3">
            <div
              v-for="activity in reportData.recentActivity"
              :key="activity.id"
              class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div>
                <div class="font-medium text-gray-800">{{ activity.subject_name }}</div>
                <div class="text-sm text-gray-500">{{ formatDate(activity.date) }}</div>
              </div>
              <div class="text-right">
                <div class="font-semibold" :class="activity.score >= 70 ? 'text-green-600' : activity.score >= 50 ? 'text-orange-600' : 'text-red-600'">
                  {{ activity.score }}%
                </div>
                <div class="text-xs text-gray-500">{{ activity.questions }} questions</div>
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
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useQuizStore } from '../stores/quiz'
import { progressReportsService } from '../services/progressReportsService'

const router = useRouter()
const authStore = useAuthStore()
const quizStore = useQuizStore()

const loading = ref(true)
const selectedSubjectId = ref(null)
const reportPeriod = ref('month')
const reportData = ref({
  totalQuizzes: 0,
  totalQuestions: 0,
  averageScore: 0,
  studyStreak: 0,
  subjectBreakdown: [],
  recentActivity: []
})

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

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' })
}

const generateReport = async () => {
  if (!authStore.user) return
  
  loading.value = true
  try {
    const result = await progressReportsService.generateReport(
      authStore.user.id,
      selectedSubjectId.value,
      reportPeriod.value
    )
    
    if (result.success) {
      reportData.value = result.data
    }
  } catch (error) {
    console.error('Error generating report:', error)
  } finally {
    loading.value = false
  }
}

const exportReport = () => {
  // Simple text export (can be enhanced to PDF later)
  const reportText = `
PROGRESS REPORT - Ed-Eureka
Generated: ${new Date().toLocaleDateString()}

SUMMARY:
- Total Quizzes: ${reportData.value.totalQuizzes}
- Total Questions: ${reportData.value.totalQuestions}
- Average Score: ${reportData.value.averageScore.toFixed(1)}%
- Study Streak: ${reportData.value.studyStreak} days

SUBJECT BREAKDOWN:
${reportData.value.subjectBreakdown.map(s => `
${s.name}:
  - Quizzes: ${s.quizzes}
  - Questions: ${s.questions}
  - Average Score: ${s.averageScore.toFixed(1)}%
  - Mistakes: ${s.mistakes}
`).join('')}
  `.trim()

  const blob = new Blob([reportText], { type: 'text/plain' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `progress-report-${new Date().toISOString().split('T')[0]}.txt`
  a.click()
  URL.revokeObjectURL(url)
}

onMounted(async () => {
  await authStore.initialize()
  await quizStore.loadSubjects()
  await generateReport()
})
</script>

