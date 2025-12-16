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
          Achievements
        </h1>
        <p class="text-gray-600">Unlock badges and track your learning milestones</p>
      </div>

      <!-- Achievement Stats -->
      <div class="grid md:grid-cols-3 gap-4 mb-8">
        <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-yellow-500">
          <div class="text-3xl font-bold text-yellow-600">{{ unlockedCount }}</div>
          <div class="text-sm text-gray-600 mt-1">Unlocked</div>
        </div>
        <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-gray-400">
          <div class="text-3xl font-bold text-gray-600">{{ lockedCount }}</div>
          <div class="text-sm text-gray-600 mt-1">Locked</div>
        </div>
        <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
          <div class="text-3xl font-bold text-purple-600">{{ totalAchievements }}</div>
          <div class="text-sm text-gray-600 mt-1">Total</div>
        </div>
      </div>

      <!-- Achievements Grid -->
      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>

      <div v-else class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="achievement in achievements"
          :key="achievement.id"
          class="bg-white rounded-xl shadow-lg p-6 border-2 transition-all"
          :class="achievement.unlocked 
            ? 'border-yellow-400 bg-gradient-to-br from-yellow-50 to-amber-50' 
            : 'border-gray-200 opacity-60'"
        >
          <div class="flex items-start space-x-4">
            <div class="text-5xl">{{ achievement.unlocked ? achievement.icon : '🔒' }}</div>
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-gray-800 mb-1">{{ achievement.name }}</h3>
              <p class="text-sm text-gray-600 mb-3">{{ achievement.description }}</p>
              
              <div v-if="achievement.unlocked" class="flex items-center text-sm text-yellow-600">
                <span>✓ Unlocked</span>
                <span class="ml-2 text-xs text-gray-500">{{ formatDate(achievement.unlocked_at) }}</span>
              </div>
              
              <div v-else class="space-y-2">
                <div class="text-xs font-medium text-gray-700">Progress:</div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div
                    class="bg-gradient-to-r from-purple-500 to-blue-500 h-2 rounded-full transition-all"
                    :style="{ width: `${achievement.progress}%` }"
                  ></div>
                </div>
                <div class="text-xs text-gray-500">{{ achievement.progressText }}</div>
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
import { achievementsService } from '../services/achievementsService'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(true)
const achievements = ref([])

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

const unlockedCount = computed(() => {
  return achievements.value.filter(a => a.unlocked).length
})

const lockedCount = computed(() => {
  return achievements.value.filter(a => !a.unlocked).length
})

const totalAchievements = computed(() => {
  return achievements.value.length
})

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

const loadAchievements = async () => {
  if (!authStore.user) return
  
  loading.value = true
  try {
    const result = await achievementsService.getAchievements(authStore.user.id)
    if (result.success) {
      achievements.value = result.data || []
    }
  } catch (error) {
    console.error('Error loading achievements:', error)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await authStore.initialize()
  await loadAchievements()
})
</script>

