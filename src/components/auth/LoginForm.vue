<template>
  <form @submit.prevent="handleSubmit" class="space-y-6">
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
        Email <span class="text-red-500">*</span>
      </label>
      <input
        id="email"
        v-model="form.email"
        type="email"
        required
        class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition"
        placeholder="Enter your email"
      />
      <p v-if="errors.email" class="mt-1 text-sm text-red-600">{{ errors.email }}</p>
    </div>

    <div>
      <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
        Password <span class="text-red-500">*</span>
      </label>
      <input
        id="password"
        v-model="form.password"
        type="password"
        required
        class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition"
        placeholder="Enter your password"
      />
      <p v-if="errors.password" class="mt-1 text-sm text-red-600">{{ errors.password }}</p>
    </div>

    <div v-if="errorMessage" class="p-3 bg-red-50 border border-red-200 rounded-lg">
      <p class="text-sm text-red-600">{{ errorMessage }}</p>
    </div>

    <button
      type="submit"
      :disabled="loading"
      class="w-full bg-gradient-to-r from-purple-600 to-blue-600 text-white py-3 px-4 rounded-xl hover:from-purple-700 hover:to-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-lg font-semibold"
    >
      <span v-if="loading">Signing in...</span>
      <span v-else>Sign In</span>
    </button>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../../stores/auth'
import { validators } from '../../utils/validators'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const form = reactive({
  email: '',
  password: ''
})

const errors = reactive({
  email: null,
  password: null
})

const errorMessage = ref('')
const loading = ref(false)

const handleSubmit = async () => {
  // Reset errors
  errors.email = null
  errors.password = null
  errorMessage.value = ''

  // Validate
  errors.email = validators.email(form.email)
  errors.password = validators.password(form.password)

  if (errors.email || errors.password) {
    return
  }

  loading.value = true
  const result = await authStore.signIn(form.email, form.password)
  loading.value = false

  if (result.success) {
    const redirect = route.query.redirect || '/dashboard'
    router.push(redirect)
  } else {
    errorMessage.value = result.error || 'Invalid email or password'
  }
}
</script>

