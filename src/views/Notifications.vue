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
            <button
              @click="markAllAsRead"
              class="text-sm text-purple-600 hover:text-purple-700 font-medium"
            >
              Mark all as read
            </button>
            <span class="text-gray-700 font-medium">{{ userDisplayName }}</span>
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center text-white font-semibold shadow-md">
              {{ userInitials }}
            </div>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="mb-8">
        <h1 class="text-4xl font-bold mb-2 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
          Notifications
        </h1>
        <p class="text-gray-600">Stay updated with your learning progress</p>
      </div>

      <!-- Notification Stats -->
      <div class="grid md:grid-cols-2 gap-4 mb-6">
        <div class="bg-white rounded-xl shadow-lg p-4 border-l-4 border-blue-500">
          <div class="text-2xl font-bold text-blue-600">{{ unreadCount }}</div>
          <div class="text-sm text-gray-600 mt-1">Unread</div>
        </div>
        <div class="bg-white rounded-xl shadow-lg p-4 border-l-4 border-green-500">
          <div class="text-2xl font-bold text-green-600">{{ totalNotifications }}</div>
          <div class="text-sm text-gray-600 mt-1">Total</div>
        </div>
      </div>

      <!-- Notifications List -->
      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>

      <div v-else-if="notifications.length === 0" class="bg-white rounded-xl shadow-lg p-12 text-center">
        <div class="text-6xl mb-4">🔔</div>
        <h3 class="text-2xl font-semibold text-gray-800 mb-2">No Notifications</h3>
        <p class="text-gray-600">You're all caught up! New notifications will appear here.</p>
      </div>

      <div v-else class="space-y-3">
        <div
          v-for="notification in notifications"
          :key="notification.id"
          class="bg-white rounded-xl shadow-md p-4 border-l-4 transition-all hover:shadow-lg"
          :class="notification.read ? 'border-gray-300 opacity-75' : 'border-purple-500'"
          @click="markAsRead(notification.id)"
        >
          <div class="flex items-start space-x-4">
            <div class="text-3xl">{{ notification.icon }}</div>
            <div class="flex-1">
              <div class="flex items-start justify-between">
                <div>
                  <h3 class="font-semibold text-gray-800 mb-1">{{ notification.title }}</h3>
                  <p class="text-sm text-gray-600 mb-2">{{ notification.message }}</p>
                  <p class="text-xs text-gray-500">{{ formatTime(notification.created_at) }}</p>
                </div>
                <div v-if="!notification.read" class="w-2 h-2 bg-purple-500 rounded-full mt-2"></div>
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
import { notificationsService } from '../services/notificationsService'

const router = useRouter()
const authStore = useAuthStore()

const loading = ref(true)
const notifications = ref([])

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

const unreadCount = computed(() => {
  return notifications.value.filter(n => !n.read).length
})

const totalNotifications = computed(() => {
  return notifications.value.length
})

const formatTime = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`
  if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

const loadNotifications = async () => {
  if (!authStore.user) return
  
  loading.value = true
  try {
    const result = await notificationsService.getNotifications(authStore.user.id)
    if (result.success) {
      notifications.value = result.data || []
    }
  } catch (error) {
    console.error('Error loading notifications:', error)
  } finally {
    loading.value = false
  }
}

const markAsRead = async (notificationId) => {
  try {
    const result = await notificationsService.markAsRead(notificationId)
    if (result.success) {
      await loadNotifications()
    }
  } catch (error) {
    console.error('Error marking notification as read:', error)
  }
}

const markAllAsRead = async () => {
  try {
    const result = await notificationsService.markAllAsRead(authStore.user.id)
    if (result.success) {
      await loadNotifications()
    }
  } catch (error) {
    console.error('Error marking all as read:', error)
  }
}

onMounted(async () => {
  await authStore.initialize()
  await loadNotifications()
})
</script>

