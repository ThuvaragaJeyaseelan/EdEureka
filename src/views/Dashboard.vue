<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-cyan-50">
    <!-- Dashboard Navbar -->
    <nav class="bg-white shadow-xl border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center space-x-6">
            <router-link to="/dashboard" class="text-2xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
              Ed-Eureka
            </router-link>
            <SubjectSelector @subject-selected="handleSubjectSelected" />
          </div>
          
          <div class="flex items-center space-x-4">
            <span class="text-gray-700 font-medium">{{ userDisplayName }}</span>
            <div class="relative" ref="profileDropdown">
              <button
                @click="showProfileMenu = !showProfileMenu"
                class="flex items-center space-x-2 focus:outline-none"
              >
                <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center text-white font-semibold shadow-md">
                  {{ userInitials }}
                </div>
              </button>
              <div
                v-if="showProfileMenu"
                class="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-xl py-2 z-50 border border-gray-100"
              >
                <button
                  @click="showHelp = true"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-purple-50 hover:text-purple-600 transition"
                >
                  Help
                </button>
                <button
                  @click="handleLogout"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Student Profile -->
      <div class="mb-6">
        <StudentProfile />
      </div>

      <!-- Quick Actions -->
      <div class="mb-8">
        <h2 class="text-2xl font-bold mb-4 text-gray-800">Quick Actions</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
          <button
            @click="$router.push('/study-plans')"
            class="bg-white p-4 rounded-xl shadow-md hover:shadow-xl transition-all transform hover:-translate-y-1 text-left border-t-4 border-purple-500 cursor-pointer"
          >
            <div class="text-2xl mb-2">📅</div>
            <div class="font-semibold text-gray-800">Study Plans</div>
            <div class="text-sm text-gray-500">Create & manage</div>
          </button>
          <button
            @click="$router.push('/progress-reports')"
            class="bg-white p-4 rounded-xl shadow-md hover:shadow-xl transition-all transform hover:-translate-y-1 text-left border-t-4 border-blue-500 cursor-pointer"
          >
            <div class="text-2xl mb-2">📊</div>
            <div class="font-semibold text-gray-800">Progress Reports</div>
            <div class="text-sm text-gray-500">View detailed reports</div>
          </button>
          <button
            @click="$router.push('/achievements')"
            class="bg-white p-4 rounded-xl shadow-md hover:shadow-xl transition-all transform hover:-translate-y-1 text-left border-t-4 border-cyan-500 cursor-pointer relative"
          >
            <div class="text-2xl mb-2">🏆</div>
            <div class="font-semibold text-gray-800">Achievements</div>
            <div class="text-sm text-gray-500">Unlock badges</div>
            <span v-if="unlockedAchievementsCount > 0" class="absolute top-2 right-2 bg-yellow-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">
              {{ unlockedAchievementsCount }}
            </span>
          </button>
          <button
            @click="$router.push('/notifications')"
            class="bg-white p-4 rounded-xl shadow-md hover:shadow-xl transition-all transform hover:-translate-y-1 text-left border-t-4 border-green-500 cursor-pointer relative"
          >
            <div class="text-2xl mb-2">🔔</div>
            <div class="font-semibold text-gray-800">Notifications</div>
            <div class="text-sm text-gray-500">Stay updated</div>
            <span v-if="unreadNotificationsCount > 0" class="absolute top-2 right-2 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center">
              {{ unreadNotificationsCount }}
            </span>
          </button>
        </div>
      </div>

      <!-- Subject Filter -->
      <div class="mb-6 flex items-center justify-between">
        <h2 class="text-2xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
          Analytics Dashboard
        </h2>
        <div class="flex items-center space-x-4">
          <label class="text-sm font-medium text-gray-700">Filter by Subject:</label>
          <select
            v-model="selectedSubjectId"
            @change="refreshAnalytics"
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
      </div>

      <!-- Analytics Section -->
      <div class="grid md:grid-cols-2 gap-6 mb-8">
        <AnalyticsChart
          :title="selectedSubjectId ? `Daily Practice - ${getSubjectName(selectedSubjectId)}` : 'Daily Practice (Last 30 Days)'"
          :chart-data="dailyPracticeData"
          chart-type="bar"
          :loading="analyticsStore.loading"
        />
        <AnalyticsChart
          :title="selectedSubjectId ? `Learning Curve - ${getSubjectName(selectedSubjectId)}` : 'Learning Curve'"
          :chart-data="learningCurveData"
          chart-type="line"
          :loading="analyticsStore.loading"
        />
      </div>

      <!-- Mistake Analytics -->
      <div v-if="analyticsStore.mistakeAnalytics" class="mb-8">
        <div class="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
          <h3 class="text-xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Mistake Analytics
          </h3>
          <div class="grid md:grid-cols-3 gap-4">
            <div class="text-center p-4 bg-red-50 rounded-xl border-2 border-red-200">
              <div class="text-3xl font-bold text-red-600">{{ analyticsStore.mistakeAnalytics.totalMistakes }}</div>
              <div class="text-sm text-gray-600 mt-1">Total Mistakes</div>
            </div>
            <div class="text-center p-4 bg-orange-50 rounded-xl border-2 border-orange-200">
              <div class="text-3xl font-bold text-orange-600">{{ analyticsStore.mistakeAnalytics.mistakeRate.toFixed(1) }}%</div>
              <div class="text-sm text-gray-600 mt-1">Mistake Rate</div>
            </div>
            <div class="text-center p-4 bg-blue-50 rounded-xl border-2 border-blue-200">
              <div class="text-3xl font-bold text-blue-600">{{ (100 - analyticsStore.mistakeAnalytics.mistakeRate).toFixed(1) }}%</div>
              <div class="text-sm text-gray-600 mt-1">Accuracy Rate</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Leaderboard -->
      <div class="mb-8">
        <Leaderboard
          :leaderboard="filteredLeaderboard"
          :loading="analyticsStore.loading"
          :subject-name="selectedSubjectId ? getSubjectName(selectedSubjectId) : null"
        />
      </div>
    </main>

    <!-- Help Modal -->
    <div
      v-if="showHelp"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      @click="showHelp = false"
    >
      <div
        class="bg-white rounded-lg p-6 max-w-md mx-4"
        @click.stop
      >
        <h3 class="text-xl font-semibold mb-4">Help & Support</h3>
        <p class="text-gray-600 mb-4">
          Need help? Here are some resources:
        </p>
        <ul class="list-disc list-inside space-y-2 text-gray-600 mb-4">
          <li>Select a subject from the dropdown to start practicing</li>
          <li>View your progress in the analytics charts</li>
          <li>Check the leaderboard to see top performers</li>
          <li>Use AI features for instant help and summarization</li>
        </ul>
        <button
          @click="showHelp = false"
          class="w-full bg-gradient-to-r from-purple-600 to-blue-600 text-white py-2 px-4 rounded-xl hover:from-purple-700 hover:to-blue-700 transition shadow-md"
        >
          Close
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, onActivated, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useAnalyticsStore } from '../stores/analytics'
import { useQuizStore } from '../stores/quiz'
import StudentProfile from '../components/dashboard/StudentProfile.vue'
import SubjectSelector from '../components/dashboard/SubjectSelector.vue'
import AnalyticsChart from '../components/dashboard/AnalyticsChart.vue'
import Leaderboard from '../components/dashboard/Leaderboard.vue'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const analyticsStore = useAnalyticsStore()
const quizStore = useQuizStore()

const getSubjectName = (subjectId) => {
  const subject = quizStore.subjects.find(s => s.id === subjectId)
  return subject ? subject.name : 'Unknown'
}

const showProfileMenu = ref(false)
const showHelp = ref(false)
const profileDropdown = ref(null)
const selectedSubjectId = ref(null)
const unlockedAchievementsCount = ref(0)
const unreadNotificationsCount = ref(0)

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

const dailyPracticeData = computed(() => {
  let data = analyticsStore.dailyPractice
  if (selectedSubjectId.value) {
    data = data.filter(item => item.subject_id === selectedSubjectId.value)
  }
  return data.map(item => ({
    practice_date: item.practice_date,
    questions_attempted: item.questions_attempted
  }))
})

const learningCurveData = computed(() => {
  let data = analyticsStore.dailyPractice
  if (selectedSubjectId.value) {
    data = data.filter(item => item.subject_id === selectedSubjectId.value)
  }
  return data.map(item => ({
    practice_date: item.practice_date,
    average_score: item.average_score
  }))
})

const filteredLeaderboard = computed(() => {
  if (!selectedSubjectId.value) {
    return analyticsStore.leaderboard
  }
  return analyticsStore.leaderboard.filter(item => {
    // Leaderboard items might have subject info, filter if available
    return true // For now, show all leaderboard items
  })
})

const handleSubjectSelected = (subject) => {
  selectedSubjectId.value = subject ? subject.id : null
  refreshAnalytics()
}

const handleLogout = async () => {
  showProfileMenu.value = false
  await authStore.signOut()
}

const handleClickOutside = (event) => {
  if (profileDropdown.value && !profileDropdown.value.contains(event.target)) {
    showProfileMenu.value = false
  }
}

const refreshAnalytics = async () => {
  if (authStore.user) {
    console.log('Refreshing analytics for subject:', selectedSubjectId.value)
    await Promise.all([
      analyticsStore.loadDailyPractice(authStore.user.id, selectedSubjectId.value),
      analyticsStore.loadLeaderboard(selectedSubjectId.value),
      analyticsStore.loadMistakeAnalytics(authStore.user.id, selectedSubjectId.value),
      loadQuickActionCounts()
    ])
    console.log('Analytics refreshed')
  }
}

const loadQuickActionCounts = async () => {
  if (!authStore.user) return
  
  try {
    // Load achievements count
    const achievementsResult = await achievementsService.getAchievements(authStore.user.id)
    if (achievementsResult.success) {
      unlockedAchievementsCount.value = achievementsResult.data?.filter(a => a.unlocked).length || 0
    }
    
    // Load notifications count
    const notificationsResult = await notificationsService.getNotifications(authStore.user.id)
    if (notificationsResult.success) {
      unreadNotificationsCount.value = notificationsResult.data?.filter(n => !n.read).length || 0
    }
  } catch (error) {
    console.error('Error loading quick action counts:', error)
  }
}

onMounted(async () => {
  await authStore.initialize()
  await refreshAnalytics()
  document.addEventListener('click', handleClickOutside)
})

onActivated(async () => {
  console.log('Dashboard activated, refreshing analytics...')
  await refreshAnalytics()
})

// Watch for route changes to refresh analytics
watch(() => route.name, async (newRoute) => {
  if (newRoute === 'Dashboard') {
    console.log('Navigated to Dashboard, refreshing analytics...')
    await refreshAnalytics()
  }
}, { immediate: false })

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

