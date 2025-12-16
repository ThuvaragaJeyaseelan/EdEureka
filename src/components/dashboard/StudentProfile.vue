<template>
  <div class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500">
    <h3 class="text-xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">Student Profile</h3>
    <div class="space-y-3">
      <div class="flex items-center">
        <span class="text-gray-600 w-24">Name:</span>
        <span class="ml-2 font-medium text-gray-800">{{ userDisplayName }}</span>
      </div>
      <div class="flex items-center">
        <span class="text-gray-600 w-24">Email:</span>
        <span class="ml-2 font-medium text-gray-800">{{ userEmail }}</span>
      </div>
      <div class="flex items-center">
        <span class="text-gray-600 w-24">Member since:</span>
        <span class="ml-2 font-medium text-gray-800">{{ memberSince }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '../../stores/auth'

const authStore = useAuthStore()

const userDisplayName = computed(() => {
  if (!authStore.user) return 'N/A'
  return authStore.user.user_metadata?.name || authStore.user.email?.split('@')[0] || 'User'
})

const userEmail = computed(() => {
  return authStore.user?.email || 'N/A'
})

const memberSince = computed(() => {
  if (!authStore.user?.created_at) return 'N/A'
  const date = new Date(authStore.user.created_at)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
})
</script>

