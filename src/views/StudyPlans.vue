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
          Study Plans
        </h1>
        <p class="text-gray-600">Create and manage your study schedule</p>
      </div>

      <!-- Create New Plan Button -->
      <div class="mb-6">
        <button
          @click="showCreateModal = true"
          class="px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition shadow-lg font-semibold"
        >
          + Create New Study Plan
        </button>
      </div>

      <!-- Study Plans Grid -->
      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>

      <div v-else-if="studyPlans.length === 0" class="bg-white rounded-xl shadow-lg p-12 text-center">
        <div class="text-6xl mb-4">📅</div>
        <h3 class="text-2xl font-semibold text-gray-800 mb-2">No Study Plans Yet</h3>
        <p class="text-gray-600 mb-4">Create your first study plan to organize your learning schedule.</p>
        <button
          @click="showCreateModal = true"
          class="px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition shadow-lg font-semibold"
        >
          Create Study Plan
        </button>
      </div>

      <div v-else class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="plan in studyPlans"
          :key="plan.id"
          class="bg-white rounded-xl shadow-lg p-6 border-l-4 border-purple-500 hover:shadow-xl transition"
        >
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-xl font-semibold text-gray-800 mb-1">{{ plan.title }}</h3>
              <p class="text-sm text-gray-500">{{ plan.subject_name }}</p>
            </div>
            <button
              @click="deletePlan(plan.id)"
              class="text-red-500 hover:text-red-700 text-xl"
              title="Delete plan"
            >
              ×
            </button>
          </div>
          
          <div class="space-y-2 mb-4">
            <div class="flex items-center text-sm text-gray-600">
              <span class="font-medium mr-2">Start:</span>
              <span>{{ formatDate(plan.start_date) }}</span>
            </div>
            <div class="flex items-center text-sm text-gray-600">
              <span class="font-medium mr-2">End:</span>
              <span>{{ formatDate(plan.end_date) }}</span>
            </div>
            <div class="flex items-center text-sm text-gray-600">
              <span class="font-medium mr-2">Daily Goal:</span>
              <span>{{ plan.daily_goal }} questions/day</span>
            </div>
          </div>

          <div class="mt-4 pt-4 border-t border-gray-200">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Progress</span>
              <span class="text-sm font-semibold text-purple-600">{{ plan.progress }}%</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div
                class="bg-gradient-to-r from-purple-500 to-blue-500 h-2 rounded-full transition-all"
                :style="{ width: `${plan.progress}%` }"
              ></div>
            </div>
          </div>

          <div v-if="plan.description" class="mt-4 text-sm text-gray-600">
            {{ plan.description }}
          </div>
        </div>
      </div>
    </main>

    <!-- Create Study Plan Modal -->
    <Teleport to="body">
      <div
        v-if="showCreateModal"
        class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[9999] p-4"
        @click.self="showCreateModal = false"
      >
        <div
          class="bg-white rounded-lg p-6 max-w-md w-full max-h-[90vh] overflow-y-auto shadow-2xl"
          @click.stop
        >
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-xl font-semibold text-gray-800">Create Study Plan</h3>
            <button
              @click="showCreateModal = false"
              class="text-gray-500 hover:text-gray-700 text-2xl font-bold"
            >
              ×
            </button>
          </div>

          <form @submit.prevent="createPlan" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Plan Title</label>
              <input
                v-model="newPlan.title"
                type="text"
                required
                class="w-full px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                placeholder="e.g., AL Maths Preparation"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Subject</label>
              <select
                v-model="newPlan.subject_id"
                required
                class="w-full px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
              >
                <option value="">Select a subject</option>
                <option
                  v-for="subject in quizStore.subjects"
                  :key="subject.id"
                  :value="subject.id"
                >
                  {{ subject.name }}
                </option>
              </select>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Start Date</label>
                <input
                  v-model="newPlan.start_date"
                  type="date"
                  required
                  class="w-full px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">End Date</label>
                <input
                  v-model="newPlan.end_date"
                  type="date"
                  required
                  class="w-full px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Daily Goal (Questions)</label>
              <input
                v-model.number="newPlan.daily_goal"
                type="number"
                required
                min="1"
                class="w-full px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                placeholder="e.g., 20"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Description (Optional)</label>
              <textarea
                v-model="newPlan.description"
                rows="3"
                class="w-full px-4 py-2 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                placeholder="Add any notes or goals for this plan..."
              ></textarea>
            </div>

            <div class="flex space-x-4">
              <button
                type="submit"
                :disabled="creatingPlan"
                class="flex-1 px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 disabled:opacity-50 transition shadow-lg font-semibold"
              >
                <span v-if="creatingPlan">Creating...</span>
                <span v-else>Create Plan</span>
              </button>
              <button
                type="button"
                @click="showCreateModal = false"
                class="px-6 py-3 bg-gray-200 text-gray-700 rounded-xl hover:bg-gray-300 transition font-medium"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useQuizStore } from '../stores/quiz'
import { studyPlansService } from '../services/studyPlansService'
import { Teleport } from 'vue'

const router = useRouter()
const authStore = useAuthStore()
const quizStore = useQuizStore()

const loading = ref(true)
const studyPlans = ref([])
const showCreateModal = ref(false)
const creatingPlan = ref(false)

const newPlan = ref({
  title: '',
  subject_id: '',
  start_date: '',
  end_date: '',
  daily_goal: 20,
  description: ''
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
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
}

const loadStudyPlans = async () => {
  if (!authStore.user) return
  
  loading.value = true
  try {
    const result = await studyPlansService.getStudyPlans(authStore.user.id)
    if (result.success) {
      studyPlans.value = result.data || []
    }
  } catch (error) {
    console.error('Error loading study plans:', error)
  } finally {
    loading.value = false
  }
}

const createPlan = async () => {
  if (!authStore.user) return
  
  creatingPlan.value = true
  try {
    const result = await studyPlansService.createStudyPlan({
      ...newPlan.value,
      user_id: authStore.user.id
    })
    
    if (result.success) {
      await loadStudyPlans()
      showCreateModal.value = false
      // Reset form
      newPlan.value = {
        title: '',
        subject_id: '',
        start_date: '',
        end_date: '',
        daily_goal: 20,
        description: ''
      }
    } else {
      alert('Failed to create study plan: ' + (result.error || 'Unknown error'))
    }
  } catch (error) {
    console.error('Error creating study plan:', error)
    alert('Failed to create study plan. Please try again.')
  } finally {
    creatingPlan.value = false
  }
}

const deletePlan = async (planId) => {
  if (!confirm('Are you sure you want to delete this study plan?')) return
  
  try {
    const result = await studyPlansService.deleteStudyPlan(planId)
    if (result.success) {
      await loadStudyPlans()
    } else {
      alert('Failed to delete study plan: ' + (result.error || 'Unknown error'))
    }
  } catch (error) {
    console.error('Error deleting study plan:', error)
    alert('Failed to delete study plan. Please try again.')
  }
}

onMounted(async () => {
  await authStore.initialize()
  await quizStore.loadSubjects()
  await loadStudyPlans()
})
</script>

