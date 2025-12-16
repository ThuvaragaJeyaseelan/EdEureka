<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-cyan-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-4xl font-extrabold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
          Sign in to your account
        </h2>
        <p class="mt-2 text-center text-sm text-gray-600">
          Or
          <router-link to="/signup" class="font-medium text-purple-600 hover:text-purple-700 transition">
            create a new account
          </router-link>
        </p>
      </div>
      <div class="bg-white py-8 px-6 shadow-2xl rounded-2xl border border-gray-100">
        <LoginForm />
      </div>
    </div>
  </div>
</template>

<script setup>
import LoginForm from '../components/auth/LoginForm.vue'
</script>

