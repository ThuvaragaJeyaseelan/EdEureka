<template>
  <nav class="bg-white shadow-xl border-b border-gray-200">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <div class="flex items-center">
          <router-link to="/" class="text-2xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Ed-Eureka
          </router-link>
        </div>
        
        <div class="flex items-center space-x-4">
          <template v-if="!authStore.isAuthenticated">
            <router-link
              to="/login"
              class="px-4 py-2 text-gray-700 hover:text-purple-600 transition font-medium"
            >
              Login
            </router-link>
            <router-link
              to="/signup"
              class="px-4 py-2 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition shadow-md font-semibold"
            >
              Sign Up
            </router-link>
          </template>
          
          <template v-else>
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
                  <router-link
                    to="/dashboard"
                    class="block px-4 py-2 text-sm text-gray-700 hover:bg-purple-50 hover:text-purple-600 transition"
                    @click="showProfileMenu = false"
                  >
                    Dashboard
                  </router-link>
                  <button
                    @click="handleLogout"
                    class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition"
                  >
                    Logout
                  </button>
                </div>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()
const showProfileMenu = ref(false)
const profileDropdown = ref(null)

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

const handleLogout = async () => {
  showProfileMenu.value = false
  await authStore.signOut()
}

const handleClickOutside = (event) => {
  if (profileDropdown.value && !profileDropdown.value.contains(event.target)) {
    showProfileMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

