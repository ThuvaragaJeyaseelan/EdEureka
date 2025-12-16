<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-cyan-50">
    <Navbar />
    
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Hero Section -->
      <div class="text-center mb-16">
        <h1 class="text-6xl font-bold bg-gradient-to-r from-purple-600 via-blue-600 to-cyan-600 bg-clip-text text-transparent mb-4">
          Ed-Eureka
        </h1>
        <p class="text-xl text-gray-700 mb-8 max-w-3xl mx-auto">
          Master your AL exams with comprehensive MCQ practice for Combined Maths, Physics, Chemistry, and Biology. 
          Track your progress, compete on leaderboards, and get AI-powered assistance.
        </p>
        <div v-if="!authStore.isAuthenticated" class="flex justify-center space-x-4">
          <router-link
            to="/signup"
            class="px-8 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all transform hover:scale-105 shadow-lg text-lg font-semibold"
          >
            Get Started
          </router-link>
          <router-link
            to="/login"
            class="px-8 py-3 bg-white text-purple-600 rounded-xl hover:bg-purple-50 transition-all transform hover:scale-105 text-lg font-semibold border-2 border-purple-600 shadow-md"
          >
            Sign In
          </router-link>
        </div>
      </div>

      <!-- Features Section -->
      <div class="grid md:grid-cols-3 gap-8 mb-16">
        <div class="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:-translate-y-1 border-t-4 border-purple-500">
          <div class="text-4xl mb-4">📚</div>
          <h3 class="text-xl font-semibold mb-2 text-gray-800">Comprehensive Question Bank</h3>
          <p class="text-gray-600">
            Access thousands of MCQs for Combined Maths, Physics, Chemistry, and Biology. 
            Practice with randomized questions tailored to your needs.
          </p>
        </div>

        <div class="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:-translate-y-1 border-t-4 border-blue-500">
          <div class="text-4xl mb-4">📊</div>
          <h3 class="text-xl font-semibold mb-2 text-gray-800">Track Your Progress</h3>
          <p class="text-gray-600">
            Monitor your daily practice, view detailed analytics, and see your learning curve 
            improve over time with visual charts and reports.
          </p>
        </div>

        <div class="bg-white p-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:-translate-y-1 border-t-4 border-cyan-500">
          <div class="text-4xl mb-4">🤖</div>
          <h3 class="text-xl font-semibold mb-2 text-gray-800">AI-Powered Assistance</h3>
          <p class="text-gray-600">
            Get instant help with AI chat, summarize long texts, and receive detailed explanations 
            for every question you practice.
          </p>
        </div>
      </div>

      <!-- How It Works -->
      <div class="bg-white rounded-2xl shadow-xl p-8 mb-16 border border-gray-100">
        <h2 class="text-3xl font-bold text-center mb-8 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">How It Works</h2>
        <div class="grid md:grid-cols-4 gap-6">
          <div class="text-center">
            <div class="w-16 h-16 bg-gradient-to-br from-purple-500 to-purple-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4 shadow-lg">1</div>
            <h4 class="font-semibold mb-2 text-gray-800">Sign Up</h4>
            <p class="text-gray-600 text-sm">Create your free account in seconds</p>
          </div>
          <div class="text-center">
            <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-blue-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4 shadow-lg">2</div>
            <h4 class="font-semibold mb-2 text-gray-800">Choose Subject</h4>
            <p class="text-gray-600 text-sm">Select from Combined Maths, Physics, Chemistry, or Biology</p>
          </div>
          <div class="text-center">
            <div class="w-16 h-16 bg-gradient-to-br from-cyan-500 to-cyan-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4 shadow-lg">3</div>
            <h4 class="font-semibold mb-2 text-gray-800">Practice</h4>
            <p class="text-gray-600 text-sm">Take quizzes and get instant feedback</p>
          </div>
          <div class="text-center">
            <div class="w-16 h-16 bg-gradient-to-br from-green-500 to-green-600 text-white rounded-full flex items-center justify-center text-2xl font-bold mx-auto mb-4 shadow-lg">4</div>
            <h4 class="font-semibold mb-2 text-gray-800">Improve</h4>
            <p class="text-gray-600 text-sm">Track progress and climb the leaderboard</p>
          </div>
        </div>
      </div>

      <!-- CTA Section -->
      <div v-if="!authStore.isAuthenticated" class="text-center bg-gradient-to-r from-purple-600 via-blue-600 to-cyan-600 text-white rounded-2xl p-12 shadow-2xl">
        <h2 class="text-3xl font-bold mb-4">Ready to Ace Your AL Exams with Ed-Eureka?</h2>
        <p class="text-xl mb-8 opacity-95">Join thousands of students preparing for success</p>
        <router-link
          to="/signup"
          class="inline-block px-8 py-3 bg-white text-purple-600 rounded-xl hover:bg-gray-100 transition-all transform hover:scale-105 text-lg font-semibold shadow-lg"
        >
          Start Free Today
        </router-link>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import Navbar from '../components/common/Navbar.vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

onMounted(async () => {
  await authStore.initialize()
})
</script>

